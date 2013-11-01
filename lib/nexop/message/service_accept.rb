module Nexop
  module Message
    class ServiceAccept < Base
      SSH_MSG_SERVICE_ACCEPT = 6

      ##
      # @!attribute [r] type
      # @return [Integer] Message type set to {SSH_MSG_SERVICE_ACCEPT}
      add_field(:type, type: :byte, const: SSH_MSG_SERVICE_ACCEPT)

      ##
      # @!attribute [rw] service_name
      # @return [String] The name of the service to accept
      add_field(:service_name, type: :string)
    end
  end
end
