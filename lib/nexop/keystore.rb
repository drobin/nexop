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
    end

    private

    def dir2idx(direction)
      case direction
      when :c2s then 0
      when :s2c then 1
      else raise ArgumentError, "invalid direction: #{direction}"
      end
    end
  end
end
