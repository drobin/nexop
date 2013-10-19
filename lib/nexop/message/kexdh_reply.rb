class Nexop::Message::KexdhReply < Nexop::Message::Base
  SSH_MSG_KEXDH_REPLY = 31

  add_field(:type, type: :byte, const: SSH_MSG_KEXDH_REPLY)
  add_field(:k_s, type: :string)

  ##
  # @!attribute [r] f
  # @return [Integer] the exchange value sent by the server
  add_field(:f, type: :string) { |msg| msg.dh.pub_key.to_i }

  add_field(:sig_h, type: :string)

  ##
  # The key exchange algorithm.
  #
  # The algorithm selects the prime used by the diffie hellman algorithm
  # @return [String]
  attr_accessor :kex_algorithm

  ##
  # The prime used by the diffie hellman algorithm.
  # Depends on the {#kex_algorithm}.
  # @return [Integer]
  attr_reader :p

  ##
  # The generator.
  # Depends on the {#kex_algorithm}.
  # @return [Integer]
  attr_reader :g

  ##
  # The exchange value sent by the client
  # @return [Integer]
  attr_accessor :e

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

  ##
  # The shared secret.
  #
  # @return [Integer] The shared secret
  # @raise [ArgumentError] if {#e} or {#dh} are `nil`
  def K
    raise ArgumentError, "e can't be nil" if e.nil?
    @K ||= dh.compute_key(e).unpack("C*").inject(0) { |a, e| a <<= 8; a |= e }
  end

  alias_method :shared_secret, :K

  ##
  # The `OpenSSL::PKey::DH` instance used to calculate various keys for the
  # diffie hellman algorithm.
  #
  # @return [OpenSSL::PKey::DH]
  # @raise [ArgumentError] if {#p} or {#g} are `nil`
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
