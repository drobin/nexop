module Nexop
  ##
  # Module performs the kex-exchange for a SSH connection.
  #
  # @see http://tools.ietf.org/html/rfc4253#section-7
  module Kex
    ##
    # Returns the {Message::KexInit} message for the requested direction.
    #
    # The direction can be either `:c2s` or `:s2c`:
    #
    # - `:c2s`: (_client to server_) The {Message::KexInit} message received
    #   from the ciient. The message can be assigned with {#receive_kex_init}.
    # - `:s2c`: (_server to client_) The {Message::KexInit} message send to
    #   client. The module provides the message and cannot be changed from
    #   outside.
    #
    # @param direction [:c2s, :s2c] The requested direction
    # @return [Message::KexInit] The requested message
    # @raise [ArgumentError] if the `direction` is neither `:c2s` or `:s2c`.
    def kex_init(direction)
      case direction
      when :c2s then @kex_init_c2s
      when :s2c then build_kex_init_s2c
      else raise ArgumentError, "either :c2s or :s2c expected"
      end
    end

    ##
    # Assigns the {Message::KexInit} message received from client to the
    # protocol handler.
    #
    # The message can be fetched again with {#kex_init}`(:c2s)`.
    def receive_kex_init(msg)
      @kex_init_c2s = msg
    end

    private

    def build_kex_init_s2c
      unless @kex_init_s2c
        @kex_init_s2c = Message::KexInit.new
        @kex_init_s2c.kex_algorithms = [ "diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1" ]
        @kex_init_s2c.server_host_key_algorithms = [ "ssh-rsa" ]
        @kex_init_s2c.encryption_algorithms_client_to_server = [ "3des-cbc" ]
        @kex_init_s2c.encryption_algorithms_server_to_client = [ "3des-cbc" ]
        @kex_init_s2c.mac_algorithms_client_to_server = [ "hmac-sha1" ]
        @kex_init_s2c.mac_algorithms_server_to_client = [ "hmac-sha1" ]
        @kex_init_s2c.compression_algorithms_client_to_server = [ "none" ]
        @kex_init_s2c.compression_algorithms_server_to_client = [ "none" ]
      end

      @kex_init_s2c
    end
  end
end
