module Nexop
  module Handler
    ##
    # Module performs the service-request for a SSH connection.
    #
    # @see http://tools.ietf.org/html/rfc4253#section-10
    class Service < Handler::Base
      include Log

      def initialize
        @services = []
      end

      ##
      # Services registered at the service-handler.
      #
      # Services registered here are accepted during the SSH protocol
      # handshake and can be started on the top on the session.
      #
      # @return [Array] Array containing all activated services of type
      #         {Service::Base}.
      attr_reader :services

      ##
      # The currently active service.
      #
      # @return [Service::Base]
      attr_reader :current_service

      ##
      # Registers a service on the service-handler.
      #
      # A registered service can be requested from the client and then be
      # started on the top of the session.
      #
      # @param service [Service::Base] The service-instance to register
      # @raise [ArgumentError] if the `service`-class is not derivated from
      #        {Service::Base}.
      def add_service(service)
        if service.is_a?(Nexop::Service::Base)
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
        if @current_service
          result = @current_service.tick(payload)
          make_finish if @current_service.finished?
          result
        else
          request = Message::ServiceRequest.parse(payload)
          log.debug("request for service '#{request.service_name}'")

          @current_service = self.services.select{ |s| s.name == request.service_name }.first
          if @current_service
            log.debug("service '#{@current_service.name} available, selected'")
            return Message::ServiceAccept.new(:service_name => request.service_name)
          else
            log.error("service '#{request.service_name}' not available, aborting")
            raise DisconnectError.new(
              Message::Disconnect::Reason::SERVICE_NOT_AVAILABLE,
              "service '#{request.service_name}' not available"
            )
          end
        end
      end
    end
  end
end
