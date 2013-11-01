module Nexop
  module Message
    class Disconnect < Base
      SSH_MSG_DISCONNECT = 1

      module Reason
        HOST_NOT_ALLOWED_TO_CONNECT = 1
        PROTOCOL_ERROR = 2
        KEY_EXCHANGE_FAILED = 3
        RESERVED = 4
        MAC_ERROR = 5
        COMPRESSION_ERROR = 6
        SERVICE_NOT_AVAILABLE = 7
        PROTOCOL_VERSION_NOT_SUPPORTED = 8
        HOST_KEY_NOT_VERIFIABLE = 9
        CONNECTION_LOST = 10
        BY_APPLICATION = 11
        TOO_MANY_CONNECTIONS = 12
        AUTH_CANCELLED_BY_USER = 13
        NO_MORE_AUTH_METHODS_AVAILABLE = 14
        ILLEGAL_USER_NAME = 15
      end

      ##
      # @!attribute [r] type
      # @return [Integer] Message type set to {SSH_MSG_DISCONNECT}
      add_field(:type, type: :byte, const: SSH_MSG_DISCONNECT)

      ##
      # @!attribute [rw] reason_code
      # @return [Integer] The reason in a more machine-readable format
      add_field(:reason_code, type: :uint32)

      ##
      # @!attribute [rw] description
      # @return [String] A specific explanation in a human-readable form
      add_field(:description, type: :string, default: "")

      ##
      # @!attribute [rw] language_tag
      # @return [String] Language used in {#description}
      add_field(:language_tag, type: :string, default: "")
    end
  end
end
