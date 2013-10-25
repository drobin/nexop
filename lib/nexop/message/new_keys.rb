module Nexop
  module Message
    class NewKeys < Base
      SSH_MSG_NEWKEYS = 21

      ##
      # @!attribute [r] type
      # @return [Integer] Message type set to {SSH_MSG_NEWKEYS}
      add_field(:type, type: :byte, const: SSH_MSG_NEWKEYS)
    end
  end
end
