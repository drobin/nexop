class Nexop::Message::KexdhReply < Nexop::Message::Base
  SSH_MSG_KEXDH_REPLY = 31

  add_field(:type, type: :byte, const: SSH_MSG_KEXDH_REPLY)

  ##
  # @!attribute [r] k_s
  # @return [String] the host key
  add_field(:k_s, type: :string) { |msg| msg.hostkey.to_ssh }

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
  # The hostkey.
  #
  # @return [Hostkey] The hostkey used by the connection.
  attr_accessor :hostkey

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

  ##
  # Calculates and returns the exchange hash for the connection.
  #
  # Once calculated, the exchange hash is cached in the object
  #
  # @param v_c [String] the client's identification string (CR and LF excluded)
  # @param v_s [String] the server's identification string (CR and LF excluded)
  # @param i_c [String] the payload of the client's SSH_MSG_KEXINIT
  # @param i_s [String] the payload of the server's SSH_MSG_KEXINIT
  # @return [String] the exchange hash
  # @raise [ArgumentError] if {#e} or {#dh} are `nil`
  def H(v_c, v_s, i_c, i_s)
    unless @h
      raise ArgumentError, "e and hostkey can't be nil" if e.nil? || hostkey.nil?

      data = Nexop::Message::IO.string(:encode, v_c) +
             Nexop::Message::IO.string(:encode, v_s) +
             Nexop::Message::IO.string(:encode, i_c) +
             Nexop::Message::IO.string(:encode, i_s) +
             Nexop::Message::IO.string(:encode, hostkey.to_ssh) +
             Nexop::Message::IO.mpint(:encode, e) +
             Nexop::Message::IO.mpint(:encode, f) +
             Nexop::Message::IO.mpint(:encode, self.K)
      sha1 = OpenSSL::Digest::SHA1.new
      @h = sha1.digest(data)
    end

    @h
  end

  alias_method :exchange_hash, :H
end
