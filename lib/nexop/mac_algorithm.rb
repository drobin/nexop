module Nexop
  module MacAlgorithm
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
  end
end
