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

    ##
    # Returns the public key of the keypair.
    #
    # The key is read on-demand, the first time the method is called. Then
    # the key is cached over the lifetime of the object.
    #
    # @return [OpenSSL::PKey::RSA] The public key
    # @raise Errno::ENOENT if {#pub_path} does not exist
    def pub
      @pubkey ||= OpenSSL::PKey::RSA.new(File.read(@pub_path))
    end

    ##
    # Returns the private key of the keypair.
    #
    # The key is read on-demand, the first time the method is called. Then
    # the key is cached over the lifetime of the object.
    #
    # @return [OpenSSL::PKey::RSA] The private key
    # @raise Errno::ENOENT if {#priv_path} does not exist
    def priv
      @privkey ||= OpenSSL::PKey::RSA.new(File.read(@priv_path))
    end

    ##
    # Returns a string-representation of the {#pub public key} which can
    # be used by the SSH-protocol.
    #
    # @return [String] The encoded representation of the key
    # @see http://tools.ietf.org/html/rfc4253#section-6.6
    def to_ssh
      Nexop::Message::IO.string(:encode, "ssh-rsa") +
      Nexop::Message::IO.mpint(:encode, pub.params["e"]) +
      Nexop::Message::IO.mpint(:encode, pub.params["n"])
    end

    private

    def initialize(pub_path, priv_path)
      @pub_path = pub_path
      @priv_path = priv_path
    end
  end
end
