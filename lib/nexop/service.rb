module Nexop
  class ServiceBase < Handler::Base
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
  end
end
