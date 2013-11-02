module Nexop
  module Message
    class Debug < Base
      SSH_MSG_DEBUG = 4

      ##
      # @!attribute [r] type
      # @return [Integer] Message type set to {SSH_MSG_DEBUG}
      add_field(:type, type: :byte, const: SSH_MSG_DEBUG)

      ##
      # @!attribute [rw] always_display
      # @return [Boolean] If `true`, the message should be displayed.
      add_field(:always_display, type: :boolean, default: false)

      ##
      # @!attribute [rw] message
      # @return [String] The debugging information
      add_field(:message, type: :string)

      ##
      # @!attribute [rw] language_tag
      # @return [String] The language of the {#message}
      add_field(:language_tag, type: :string, default: "")
    end
  end
end
