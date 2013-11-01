module Nexop
  module Handler
    ##
    # Module performs the service-request for a SSH connection.
    #
    # @see http://tools.ietf.org/html/rfc4253#section-10
    class Service < Handler::Base
      ##
      # Services registered at the service-handler.
      #
      # Services registered here are accepted during the SSH protocol
      # handshake and can be started on the top on the session.
      #
      # @return [Array] Array containing all activated services of type
      #         {ServiceBase}.
      attr_reader :services

      def initialize(send_method)
        super(send_method)

        @services = []
      end

      ##
      # Registers a service on the service-handler.
      #
      # A registered service can be requested from the client and then be
      # started on the top of the session.
      #
      # @param service [ServiceBase] The service-instance to register
      # @raise [ArgumentError] if the `service`-class is not derivated from
      #        {ServiceBase}.
      def add_service(service)
        if service.is_a?(Nexop::ServiceBase)
          @services << service
        else
          raise ArgumentError, "invalid service-class: #{service.class.name}"
        end
      end

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
