class Nexop::Message::KexdhReply < Nexop::Message::Base
  SSH_MSG_KEXDH_REPLY = 31

  add_field(:type, type: :byte, const: SSH_MSG_KEXDH_REPLY)
  add_field(:k_s, type: :string)
  add_field(:f, type: :string)
  add_field(:sig_h, type: :string)
end
