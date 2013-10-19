module Nexop
  ##
  # A hostkey.
  #
  # You are able to read an hostkey from a pair of files.
  class Hostkey
    ##
    # The path, where the public key is stored.
    # @return [String]
    attr_reader :pub_path

    ##
    # The path, where the private key is stored.
    # @return [String]
    attr_reader :priv_path

    ##
    # Reads an hostkey from a pair of file.
    #
    # The private key is stored in the file `priv_path`. By default, the
    # related public key is stored in a file, where the suffix `.pub` is
    # appended to the filename `priv_path`. But you can specify a separate,
    # independent path with the `pub_path` argument.
    #
    # @param priv_path [String] The path, where the private key is stored
    # @param pub_path [String] If set to `nil`, then the path of the public
    #        key will be the path of the private key suffixed with `.pub`.
    #        When the argument is not `nil`, then this is used as the path.
    # @return [Hostkey] The related hostkey-instance
    def self.from_file(priv_path, pub_path = nil)
      hk = Hostkey.new(pub_path || "#{priv_path}.pub", priv_path)
    end

    private

    def initialize(pub_path, priv_path)
      @pub_path = pub_path
      @priv_path = priv_path
    end
  end
end
