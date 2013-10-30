module EncryptionHelper
  def encrypt(data, keystore)
    enc_spec = Nexop::EncryptionAlgorithm.from_s(keystore.encryption_algorithm(:c2s))
    mac_spec = Nexop::MacAlgorithm.from_s(keystore.mac_algorithm(:c2s))

    out = if keystore.encryption_algorithm(:c2s) != Nexop::EncryptionAlgorithm::NONE
      cipher = OpenSSL::Cipher.new(enc_spec.cipher_spec)
      cipher.encrypt
      cipher.key = keystore.encryption_key(:c2s)
      cipher.iv = keystore.initialization_vector(:c2s)
      (cipher.update(data.pack("C*")) + cipher.final)[0, data.length]
    else
      data.pack("C*")
    end

    out += if keystore.mac_algorithm(:c2s) != Nexop::MacAlgorithm::NONE
      hmac_in = [ 0 ].pack("N") + data.pack("C*")
      OpenSSL::HMAC.digest(OpenSSL::Digest.new(mac_spec.digest_spec), keystore.integrity_key(:c2s), hmac_in)
    else
      ""
    end
  end

  def decrypt(data, keystore)
    enc_spec = Nexop::EncryptionAlgorithm.from_s(keystore.encryption_algorithm(:s2c))
    mac_spec = Nexop::MacAlgorithm.from_s(keystore.mac_algorithm(:s2c))

    plain = if keystore.encryption_algorithm(:s2c) != Nexop::EncryptionAlgorithm::NONE
      cipher = OpenSSL::Cipher.new(enc_spec.cipher_spec)
      cipher.decrypt
      cipher.padding = 0
      cipher.key = keystore.encryption_key(:s2c)
      cipher.iv = keystore.initialization_vector(:s2c)
      cipher.update(data[0, data.length - mac_spec.digest_length])
    else
      data[0, data.length - mac_spec.digest_length]
    end

    if keystore.mac_algorithm(:s2c) != Nexop::MacAlgorithm::NONE
      hmac_in = [ 0 ].pack("N") + plain
      digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new(mac_spec.digest_spec), keystore.integrity_key(:s2c), hmac_in)
      digest.should == data[-(mac_spec.digest_length), mac_spec.digest_length]
    end

    plain
  end
end
