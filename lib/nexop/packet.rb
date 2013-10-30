module Nexop
  ##
  # SSH packet.
  #
  # {http://tools.ietf.org/html/rfc4253#section-6 Section 6 of RFC 4253} defines
  # a _binary packet_. This class defines methods to read and write such a
  # packet.
  #
  # @see http://tools.ietf.org/html/rfc4253#section-6
  class Packet
    ##
    # Parses a binary packet and returns the encoded payload.
    #
    # `data` is a binary string, which contains the data received over the
    # network.
    #
    # If a complete packet is encoded in `data`, then the packet is decoded and
    # the payload of the packet is returned. The packet is also removed from
    # `data`. When `data` does not contain a complete packet, then `nil` is
    # returned and `data` is kept untouched.
    #
    # @param data [String] A binary string which contains the data to be parsed.
    # @param keystore [Keystore] The keystore contains all
    #        encryption-relevant stuff (algorithms, keys, ...), which are
    #        used for decryption.
    # @param sequence_number [Integer] Sequence number used for checking
    #        data integrity (if enabled).
    # @return [String] A binary string contains the payload of the packet or
    #                  `nil` if no packet is available.
    # @raise [ArgumentError] The input `data` could not be parsed
    def self.parse(data, keystore, sequence_number)
      enc_spec = EncryptionAlgorithm.from_s(keystore.encryption_algorithm(:c2s))
      mac_spec = MacAlgorithm.from_s(keystore.mac_algorithm(:c2s))
      cipher = keystore.cipher(:c2s)
      block_size = enc_spec.block_size

      return nil if data.size < block_size

      plain = cipher.update(data[0, block_size]) # decrypt first block
      packet_length, padding_length = plain.unpack("NC")

      return nil if packet_length.nil?
      return nil if data.size < packet_length + 4 + mac_spec.digest_length # not enough data available in input-buffer

      if (packet_length + 4) % block_size != 0
        raise ArgumentError, "invalid packet-size (#{packet_length + 4}), must be a multiple of #{block_size}"
      end

      if padding_length < 4
        raise ArgumentError, "padding-size (#{padding_length}) cannot be smaller than 4"
      end

      if padding_length > packet_length - 1
        raise ArgumentError, "padding-size (#{padding_length}) cannot be larger than packet_length - 1 (#{packet_length})"
      end

      plain += cipher.update(data[block_size, packet_length + 4 - block_size]) # decrypt remaining data
      payload = plain.byteslice(5, packet_length - padding_length - 1)

      if keystore.mac_algorithm(:c2s) != MacAlgorithm::NONE
        # MAC verification
        hmac_in = [ sequence_number ].pack("N") + plain[0, packet_length + 4]
        digest = OpenSSL::HMAC.digest(OpenSSL::Digest.new(mac_spec.digest_spec), keystore.integrity_key(:c2s), hmac_in)

        if digest != data[packet_length + 4, mac_spec.digest_length]
          raise ArgumentError, "mac verification failed"
        end
      end

      # Remove data from input
      data[0, packet_length + mac_spec.digest_length + 4] = ""

      payload
    end

    ##
    # Creates a new packet, which contains the given `payload`.
    #
    # The padding of the packet is calculated accordingly.
    #
    # @param payload [String] A binary string which contains the payload of the
    #                packet, which should be created by the method.
    # @param keystore [Keystore] The keystore contains all
    #        encryption-relevant stuff (algorithms, keys, ...), which are
    #        used for encryption.
    # @param sequence_number [Integer] Sequence number used for checking
    #        data integrity (if enabled).
    # @return [String] A binary string, which contains the new packet.
    def self.create(payload, keystore, sequence_number)
      algorithm = EncryptionAlgorithm.from_s(keystore.encryption_algorithm(:s2c))
      block_size = algorithm.block_size

      length = ((payload.length + 5) / block_size.to_f).ceil * block_size
      padding_length = length - 5 - payload.length

      if padding_length < 4
        length += block_size
        padding_length = length - 5 - payload.length
      end

      data = ""
      data += [length - 4, padding_length].pack("NC")
      data += payload
      data += Array.new(padding_length, 0).pack("C*")

      keystore.cipher(:s2c).update(data)
    end
  end
end
