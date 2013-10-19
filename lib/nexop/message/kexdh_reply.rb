class Nexop::Message::KexdhReply < Nexop::Message::Base
  SSH_MSG_KEXDH_REPLY = 31

  add_field(:type, type: :byte, const: SSH_MSG_KEXDH_REPLY)
  add_field(:k_s, type: :string)

  ##
  # The exchange value sent by the server
  add_field(:f, type: :string) { |msg| msg.dh.pub_key.to_i }

  add_field(:sig_h, type: :string)

  attr_accessor :kex_algorithm
  attr_reader :p
  attr_reader :g

  def kex_algorithm=(algorithm)
    p, g = case algorithm
    when "diffie-hellman-group1-sha1" then [ Nexop::Prime::MODP_GROUP1, 2 ]
    when "diffie-hellman-group14-sha1" then [ Nexop::Prime::MODP_GROUP14, 2 ]
    else raise ArgumentError, "invalid algorithm: #{algorithm}"
    end

    @kex_algorithm = algorithm
    @p = Nexop::Prime.to_i(p)
    @g = g
  end

  def dh
    unless @dh
      raise ArgumentError, "p and g can't be nil" if p.nil? || g.nil?

      @dh = OpenSSL::PKey::DH.new
      @dh.p = p
      @dh.g = g
      @dh.generate_key!
    end

    @dh
  end
end
