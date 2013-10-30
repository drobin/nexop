module Nexop
  class MacAlgorithm
    ##
    # Returns the name of the algorithm.
    # @return [String]
    attr_reader :name

    ##
    # Returns the specification of the digest-algorithm.
    #
    # The spec is used to create a `OpenSSL::Digest`-instance with the
    # correct algorithm.
    #
    # @return [String]
    attr_reader :digest_spec

    ##
    # Returns the length of the key.
    # @return [Integer]
    attr_reader :key_length

    ##
    # Returns the length of the digest.
    # @return [Integer]
    attr_reader :digest_length

    ##
    # HMAC-SHA1 (digest length = key length = 20)
    SHA1 = "hmac-sha1"

    ##
    # no MAC
    NONE = "none"

    ##
    # Tests whether the given algorithm is supported.
    #
    # @param algorithm [String] The algorithm to test
    # @return [Boolean] When the algorithm is supported, then `true` is
    #         returned, `false`otherwise.
    def self.supported?(algorithm)
      [ SHA1, NONE ].include?(algorithm)
    end

    ##
    # Creates a {MacAlgorithm}-instance for the given `algorithm`.
    #
    # @param algorithm [String] The name of the algorithm. It should be one
    #        of the algorithms defined in the class.
    # @return [MacAlgorithm] the related {MacAlgorithm}-instance
    def self.from_s(algorithm)
      if MacAlgorithm.supported?(algorithm)
        @@instances ||= {}
        @@instances[algorithm] ||= MacAlgorithm.new(algorithm, CREDENTIALS[algorithm])
      end
    end

    private

    CREDENTIALS = {
      SHA1 => {
        :digest_spec => "sha1",
        :key_length => 20,
        :digest_length => 20
      },
      NONE => {
        :digest_spec => nil,
        :key_length => 0,
        :digest_length => 0
      }
    }

    def initialize(name, credentials)
      @name = name

      credentials.each do |key, value|
        self.instance_variable_set("@#{key}", value)
      end
    end
  end
end
