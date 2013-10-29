module Nexop
  ##
  # Supported encryption algorithms.
  class EncryptionAlgorithm
    ##
    # Returns the name of the algorithm.
    # @return [String]
    attr_reader :name

    ##
    # Returns the specification of the cipher.
    #
    # The spec is used to create a `OpenSSL::Cipher`-instance with the
    # correct algorithm.
    #
    # @return [String]
    attr_reader :cipher_spec

    ##
    # Returns the block-size of the cipher.
    # @return [Integer]
    attr_reader :block_size

    ##
    # three-key 3DES in CBC mode
    DES = "3des-cbc"

    ##
    # no encryption
    NONE = "none"

    ##
    # Tests whether the given algorithm is supported.
    #
    # @param algorithm [String] The algorithm to test
    # @return [Boolean] When the algorithm is supported, then `true` is
    #         returned, `false`otherwise.
    def self.supported?(algorithm)
      [ DES, NONE ].include?(algorithm)
    end

    ##
    # Creates a {EncryptionAlgorithm}-instance for the given `algorithm`.
    #
    # @param algorithm [String] The name of the algorithm. It should be one
    #        of the algorithms defined in the class.
    # @return [EncryptionAlgorithm] the related
    #         {EncryptionAlgorithm}-instance
    def self.from_s(algorithm)
      if EncryptionAlgorithm.supported?(algorithm)
        @@instances ||= {}
        @@instances[algorithm] ||= EncryptionAlgorithm.new(algorithm, CREDENTIALS[algorithm])
      end
    end

    private

    CREDENTIALS = {
      DES => {
        :block_size => 8,
        :cipher_spec => "DES-EDE3-CBC"
      },
      NONE => {
        :block_size => 8,
        :cipher_spec => nil
      }
    }

    def initialize(name, credentials = {})
      @name = name

      credentials.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
    end
  end
end
