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
  class Session
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
    # Creates a new session.
    def initialize
      @ibuf = ""
      @obuf = ""
    end
  end
end
