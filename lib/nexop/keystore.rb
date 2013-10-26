module Nexop
  class Keystore
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
