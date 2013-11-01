module Nexop
  ##
  # Base exception class.
  class SshdError < Exception; end

  ##
  # Exception thrown by a {Session} to notify an abnormal situation.
  class SessionError < SshdError
    ##
    # Creates a {Message::Disconnect}, which is related to the given
    # exception-class.
    #
    # @return [Message::Disconnect] the related disconnect-message
    def disconnect_message
      Message::Disconnect.new(
        :reason_code => Message::Disconnect::Reason::BY_APPLICATION,
        :description => self.message || ""
      )
    end
  end

  ##
  # Error-class will lead into a disconnect with the given {#reason_code} and
  # {#description}.
  #
  # @see Message::Disconnect
  class DisconnectError < SessionError
    ##
    # The reason of the disconnect-message.
    # @return [Integer]
    # @see Message::Disconnect#reason_code
    attr_reader :reason_code

    ##
    # The description of the disconnect-message.
    # @return [String]
    # @see Message::Disconnect#description
    attr_reader :description

    def initialize(reason_code, description)
      super("#{reason_code}: #{description}")

      @reason_code = reason_code
      @description = description
    end

    def disconnect_message
      Message::Disconnect.new(
        :reason_code => self.reason_code,
        :description => self.description || ""
      )
    end
  end
end
