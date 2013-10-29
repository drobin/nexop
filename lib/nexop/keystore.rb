module Nexop
  class Keystore
    ##
    # The exchange hash of the connection.
    #
    # The exchange-hash is used to create encryption keys and initialization
    # vectors.
    #
    # @return [String]
    attr_reader :exchange_hash

    ##
    # Returns the session identifier of the connection.
    #
    # The session identifier is used to create encryption keys and
    # initialization vectors and is valid for the whole session-lifetime
    # (cannot be changed).
    #
    # The session-id is `nil`, until the first {#exchange_hash} is assigned
    # to the key-store. The initial exchange-hash is also the session-id.
    #
    # @return [String]
    attr_reader :session_id

    # The shared secret of the connection
    #
    # The shared secret is used to create encryption keys and initialization
    # vectors.
    #
    # @return [Integer]
    attr_reader :shared_secret

    def initialize
      @encryption_algorithm = Array.new(2, EncryptionAlgorithm::NONE)
      @mac_algorithm = Array.new(2, MacAlgorithm::NONE)
      @encryption_key = Array.new(2, nil)
      @initialization_vector = Array.new(2, nil)
      @integrity_key = Array.new(2, nil)
    end

    ##
    # The current encryption algorithm for the given `direction`.
    #
    # @param direction [:c2s, :s2c] Specifies the direction of the
    #        communication. Can be either _client to server_ (`:c2s`) or
    #        _server to client_ (:s2c).
    # @return [String] The current encryption algorithm which is used for the
    #         given `direction`.
    # @see EncryptionAlgorithm
    def encryption_algorithm(direction)
      @encryption_algorithm[dir2idx(direction)]
    end

    ##
    # The current MAC algorithm for the given `direction`.
    #
    # @param direction [:c2s, :s2c] Specifies the direction of the
    #        communication. Can be either _client to server_ (`:c2s`) or
    #        _server to client_ (:s2c).
    # @return [String] The current MAC algorithm which is used for the given
    #         `direction`.
    # @see MacAlgorithm
    def mac_algorithm(direction)
      @mac_algorithm[dir2idx(direction)]
    end

    ##
    # Returns the encryption-key used for encryption/decryption of data for
    # the `direction`.
    #
    # The encryption-key depends on the {#session_id}, the {#shared_secret}
    # and the {#encryption_algorithm}. Changing one of them will trigger a
    # recalculation of the encryption key. Setting the
    # {#encryption_algorithm} to {EncryptionAlgorithm::NONE} will remove the
    # encryption key.
    #
    # @param direction [:c2s, :s2c] Specifies the direction of the
    #        communication. Can be either _client to server_ (`:c2s`) or
    #        _server to client_ (:s2c).
    # @return [String] The encryption-key used for encryption-operation of
    #         the given `direction`. If encryption is disabled
    #         ({EncryptionAlgorithm::NONE}), then `nil` is returned.
    def encryption_key(direction)
      return nil if self.encryption_algorithm(direction) == EncryptionAlgorithm::NONE
      return nil if self.shared_secret.nil? || self.exchange_hash.nil?

      key = @encryption_key[dir2idx(direction)]
      return key if key # already calculated

      key = generate_key(encryption_key_char(direction))
      @encryption_key[dir2idx(direction)] = resize_key(key, 24)
    end

    ##
    # Returns the initialization vector used for encryption/decryption of
    # data for the given `direction`.
    #
    # The initialization vectors depends on the {#session_id}, the
    # {#shared_secret} and the {#encryption_algorithm}. Changing one of them
    # will trigger a recalculation of the initialization vectors. Setting the
    # {#encryption_algorithm} to {EncryptionAlgorithm::NONE} will remove the
    # initialization vectors.
    #
    # @param direction [:c2s, :s2c] Specifies the direction of the
    #        communication. Can be either _client to server_ (`:c2s`) or
    #        _server to client_ (:s2c).
    # @return [String] The initialization vector used for
    #         encryption-operation of the given `direction`. If encryption is
    #         disabled ({EncryptionAlgorithm::NONE}), then `nil` is returned.
    def initialization_vector(direction)
      @initialization_vector[dir2idx(direction)]
    end

    ##
    # Returns the integrity key used for MAC-calculation/validation for the
    # given `direction`.
    #
    # The integrity keys depends on the {#session_id}, the {#shared_secret}
    # and the {#mac_algorithm}. Changing one of them will trigger a
    # recalculation of the integrety key. Setting the MAC-algorithm to
    # {MacAlgorithm::NONE} will remove the integrty key.
    #
    # @param direction [:c2s, :s2c] Specifies the direction of the
    #        communication. Can be either _client to server_ (`:c2s`) or
    #        _server to client_ (:s2c).
    # @return [String] The integrity key used for
    #         MAC-calculation/verification for the given `direction`. If
    #         MAC-calculation is disabled ({MacAlgorithm::NONE}), then `nil`
    #         is returned.
    def integrity_key(direction)
      @integrity_key[dir2idx(direction)]
    end

    ##
    # Updates the algorithms to be used by the session.
    #
    # This will force a re-calculation of all the keys and initialization
    # vectors in the key-store.
    #
    # @param direction [:c2s, :s2c] Specifies the direction of the
    #        communication. Can be either _client to server_ (`:c2s`) or
    #        _server to client_ (:s2c).
    # @param encryption [String] The new encryption algorithm for the
    #        specified `direction`.
    # @param mac [String] The new MAC algorithm for the specified
    #        `direction`.
    # @return [Keystore]
    # @raise [ArgumentError] if `encryption` or `mac` are not supported
    #        algorithms.
    def algorithms!(direction, encryption, mac)
      unless EncryptionAlgorithm.supported?(encryption)
        raise ArgumentError, "unsupported encryption algorithm: #{encryption}"
      end

      unless MacAlgorithm.supported?(mac)
        raise ArgumentError, "unsupported mac algorithm: #{mac}"
      end

      @encryption_algorithm[dir2idx(direction)] = encryption
      @mac_algorithm[dir2idx(direction)] = mac

      # reset keys already calculated
      @encryption_key[dir2idx(direction)] = nil
    end

    ##
    # Assigns an exchange hash and a shared secret to the keystore.
    #
    # This will force a re-calculation of all the keys and initialization
    # vectors. The first exchange hash assigned to the key-store will also
    # update the {#session_id}.
    #
    # @param exchange_hash [String] the new exchange hash
    # @param shared_secret [Integer] the new shared secret
    # @return [Keystore]
    def keys!(exchange_hash, shared_secret)
      @exchange_hash = exchange_hash.clone
      @session_id = exchange_hash.clone if self.session_id.nil?
      @shared_secret = shared_secret

      # Reset keys already calculated
      [ :c2s, :s2c ].each do |direction|
        @encryption_key[dir2idx(direction)] = nil
      end
    end

    private

    def generate_key(key_char)
      sha1 = OpenSSL::Digest::SHA1.new # TODO Depends on key exchange method

      sha1 << Message::IO.mpint(:encode, self.shared_secret)
      sha1 << self.exchange_hash
      sha1 << key_char
      sha1 << self.session_id

      sha1.digest
    end

    def resize_key(key, min)
      while key.size < min
        sha1 = OpenSSL::Digest::SHA1.new # TODO Depends on key exchange method

        sha1 << Message::IO.mpint(:encode, self.shared_secret)
        sha1 << self.session_id
        sha1 << key

        key = key + sha1.digest
      end

      key
    end

    def dir2idx(direction)
      case direction
      when :c2s then 0
      when :s2c then 1
      else raise ArgumentError, "invalid direction: #{direction}"
      end
    end

    def encryption_key_char(direction)
      case direction
      when :c2s then "C"
      when :s2c then "D"
      else raise ArgumentError, "invalid direction: #{direction}"
      end
    end
  end
end
