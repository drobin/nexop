module Nexop
  module Handler
    ##
    # Module performs the service-request for a SSH connection.
    #
    # @see http://tools.ietf.org/html/rfc4253#section-10
    class Service < Handler::Base
      ##
      # Session-tick implementation for the service-request.
      #
      # The method should be called by the session as long as `true` is
      # returned.
      #
      # @param payload [String] A binary string contains the payload of a
      #        packet.
      # @return [Boolean] As long as `true` is returned, the service is still
      #         active and the method should be called again. If `false` is
      #         returned, then the key exchange is complete and you can
      #         switch to the next session-state.
      def tick(payload)
        false
      end
    end
  end
end
