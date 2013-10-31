module Nexop
  module Handler
    ##
    # Base class for all handler running on a {Session}.
    class Base
      ##
      # Initializes the handler.
      #
      # @param send_method [Method] Method used by the handler to send a
      #        {Message::Base} back to the client.
      def initialize(send_method)
        @send_method = send_method
      end

      ##
      # Sends a {Message::Base message} back to the client.
      #
      # @param message [Message::Base] The message to serialize/send.
      # @return [Base]
      # @see Session#message_write
      def send_message(message)
        @send_method.call(message)
        self
      end
    end
  end
end
