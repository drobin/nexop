module Nexop
  class ServiceBase
    ##
    # Returns the name of the service.
    #
    # The service is identified by a name.
    # @return [String]
    attr_reader :name

    ##
    # Creates a new service with the given `name`.
    #
    # @param name [String] the name of the service
    def initialize(name)
      @name = name
    end

    ##
    # Performs a single step of the service.
    #
    # The server should consume the `payload` (if present) and produce some
    # output. Depending on the service and the state of the service the
    # `payload` can be empty!
    #
    # The output can be:
    #
    # - {Message::Base}: A single message which should be send back to the
    #   client.
    # - `Array` of {Message::Base}: The `tick` operation results into more
    #   than one packet, which are all serialized and send back to the
    #   client.
    # - `:noop`: If the `:noop` symbol is returned, the service should still
    #   be open but currently no output is available.
    # - `:finished`: The service has finished its operation. The session will
    #   be destroyed.
    # - If a {SessionError} is raised, then the service results into an
    #   abnormal situation and the session will be destroyed.
    def tick(payload)
      raise NotImplementedError
    end
  end
end
