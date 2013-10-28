module Nexop
  class MacAlgorithm
    ##
    # Returns the name of the algorithm.
    # @return [String]
    attr_reader :name

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
        @@instances[algorithm] ||= MacAlgorithm.new(algorithm)
      end
    end

    private

    def initialize(algorithm)
      @name = algorithm
    end
  end
end
