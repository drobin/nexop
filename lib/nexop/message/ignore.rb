module Nexop
  module Message
    class Ignore < Base
      SSH_MSG_IGNORE = 2

      ##
      # @!attribute [r] type
      # @return [Integer] Message type set to {SSH_MSG_IGNORE}
      add_field(:type, type: :byte, const: SSH_MSG_IGNORE)

      ##
      # @!attribute [rw] data
      # @return [String] Arbitrary data assigned to the message
      add_field(:data, type: :string, default: "")
    end
  end
end
