module EncryptionHelper
  def encrypt(data, keystore)
    name = keystore.encryption_algorithm(:c2s)
    spec = Nexop::EncryptionAlgorithm.from_s(name)

    return data.pack("C*") if name == Nexop::EncryptionAlgorithm::NONE

    cipher = OpenSSL::Cipher.new(spec.cipher_spec)
    cipher.encrypt
    cipher.key = keystore.encryption_key(:c2s)
    cipher.iv = keystore.initialization_vector(:c2s)
    (cipher.update(data.pack("C*")) + cipher.final)[0, data.length]
  end
end
