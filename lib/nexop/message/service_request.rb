module Nexop
  module Message
    class ServiceRequest < Base
      SSH_MSG_SERVICE_REQUEST = 5

      ##
      # @!attribute [r] type
      # @return [Integer] Message type set to {SSH_MSG_SERVICE_REQUEST}
      add_field(:type, type: :byte, const: SSH_MSG_SERVICE_REQUEST)

      ##
      # @!attribute [rw] service_name
      # @return [String] The name of the requested service
      add_field(:service_name, type: :string)
    end
  end
end
