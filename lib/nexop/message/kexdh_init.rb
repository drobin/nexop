class Nexop::Message::KexdhInit < Nexop::Message::Base
  SSH_MSG_KEXDH_INIT = 30

  add_field(:type, type: :byte, const: SSH_MSG_KEXDH_INIT)
  add_field(:e, type: :mpint)
end
