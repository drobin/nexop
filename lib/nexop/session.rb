require "nexop/session/handler"
require "nexop/session/kex"

module Nexop
  ##
  # Abstraction of a SSH connection.
  #
  # The communication is performed over the {#ibuf} and {#obuf} buffer:
  #
  # - {#ibuf}: When data where received from the client, then put the
  #   (possible) encrypted data into the {#ibuf}-buffer.
  # - {#obuf}: The session puts data into the buffer, which needs to be send
  #   back to the client.
  #
  # The data from {#ibuf}/{#obuf} are consumed/filled with the invocation of
  # the {#tick}-method. You should leave the session open until {#tick}
  # returns `false`.
  #
  # Assign a {#hostkey} to the session before starting to {#tick} the session!
  class Session
    include Log

    ##
    # The input-buffer.
    #
    # When data where received from the client, then put the (possible)
    # encrypted data into the buffer.
    #
    # @return [String]
    attr_accessor :ibuf

    ##
    # The output-buffer.
    #
    # The session puts data into the buffer, which needs to be send back to
    # the client.
    #
    # @return [String]
    attr_accessor :obuf

    ##
    # The hostkey to be used by the session.
    #
    # @return [Hostkey]
    attr_accessor :hostkey

    ##
    # The keystore of the session.
    #
    # @return [Keystore]
    attr_reader :keystore

    ##
    # The kex exchange module
    # @return [Kex]
    attr_reader :kex

    ##
    # The identification string of the server.
    #
    # Assigned, when the string is send to the client.
    #
    # @return [String]
    attr_reader :server_identification

    ##
    # The identification string of the client.
    #
    # Assigned, when the identification-string was received from the client.
    #
    # @return [String]
    attr_reader :client_identification

    ##
    # Creates a new session.
    def initialize
      @ibuf = ""
      @obuf = ""
      @keystore = Keystore.new
      @kex = Handler::Kex.new(self.method(:message_write))
      @seq_num = { :c2s => 0, :s2c => 0 }
    end

    ##
    # Handles and incoming and outgoing data for the session.
    #
    # The protocol handshake, any encryption/decryption is handled correctly
    # by the method. You should call the method, whenever new data are
    # available in the {#ibuf}. The method tries to consume as much data as
    # possible. Depending the the current protocol state you need to send
    # back some data to the client. So, the method can assign some data to
    # the {#obuf}. Any listener registered with {#on_obuf} is informed.
    #
    # The return value of the method states how to handle the session in the
    # future. When `true` is returned, then you should leave the session open
    # for at least one more {#tick}-invocation. When `false` is returned, you
    # can destroy the session, and the underlaying socket.
    #
    # @return [Boolean] When `true` is return, you should leave the session
    #         open. A `false` value means, that the session can be closed.
    def tick
      unless @server_identification
        @server_identification = "SSH-2.0-nexop_#{Nexop::VERSION}"
        obuf_write("#{@server_identification}\r\n")
        log.debug "server identification: #{server_identification}"
        return true
      end

      unless @client_identification
        @client_identification = @ibuf.slice!(/.*\r\n/)
        @client_identification.chomp! if @client_identification
        return true if @client_identification.nil? # incomplete
        log.debug "client identification: #{client_identification}"
      end

      # parse as many packets as available in the input-buffer
      while payload = Nexop::Packet.parse(@ibuf, self.keystore, @seq_num[:c2s])
        @seq_num[:c2s] += 1

        # tick per packet-payload: quit the session when tick_payload request it
        return false unless tick_payload(payload)
      end

      true # leave the session open
    end

    ##
    # Assign a callback, which in invoked when data are appended to {#obuf}.
    #
    # @param blk [Proc] The `Proc`-instance to invoke
    # @return [Session]
    def on_obuf(&blk)
      @on_obuf = blk
      self
    end

    protected

    ##
    # Assigns data to {#obuf} and informs the {#on_obuf listener}.
    # @return [Session]
    def obuf_write(data)
      @obuf += data
      @on_obuf.call(@obuf) if @on_obuf && @on_obuf.respond_to?(:call)
      self
    end

    ##
    # Assigns a {Packet} to {#obuf}.
    #
    # From the given `payload` a SSH-packet is created and
    # {#obuf_write assigned} to {#obuf}.
    #
    # @param payload [String] The payload of a packet to send to the client.
    #
    # @return [Session]
    # @see #obuf_write
    def packet_write(payload)
      data = Packet.create(payload, self.keystore, @seq_num[:s2c])
      @seq_num[:s2c] += 1
      obuf_write(data)
    end

    ##
    # Assigns the given {Message::Base message} to {#obuf}.
    #
    # The given `message` is {Message::Base#serialize serialized} and encoded
    # into a {Packet}. The resulting data are assigned to {#obuf}.
    #
    # @param message [Message::Base] A message which should be serialized and
    #        send to the client.
    # @return [Session]
    # @see #obuf_write
    # @see #packet_write
    def message_write(message)
      serialized = message.serialize
      packet_write(serialized)
    end

    private

    ##
    # A single tick consuming the given `payload`.
    def tick_payload(payload)
      @phase ||= :kex
      log.debug("current phase: #{@phase}")

      case @phase
      when :kex
        kex.prepare(self.hostkey, self.client_identification, self.server_identification)
        @phase = :finished unless kex.tick_kex(payload)
      else
        raise "Invalid phase: #{@phase}"
      end

      @phase != :finished
    end
  end
end
