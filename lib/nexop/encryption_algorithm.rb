module Nexop
  ##
  # Supported encryption algorithms.
  module EncryptionAlgorithm
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
  end
end
