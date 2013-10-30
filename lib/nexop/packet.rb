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
    # @return [String] A binary string contains the payload of the packet or
    #                  `nil` if no packet is available.
    # @raise [ArgumentError] The input `data` could not be parsed
    def self.parse(data, keystore)
      packet_length, padding_length = data.unpack("NC")

      return nil if packet_length.nil?
      return nil if data.size < packet_length + 4

      if (packet_length + 4) % 8 != 0
        raise ArgumentError, "invalid packet-size (#{packet_length + 4}), must be a multiple of 8"
      end

      if padding_length < 4
        raise ArgumentError, "padding-size (#{padding_length}) cannot be smaller than 4"
      end

      if padding_length > packet_length - 1
        raise ArgumentError, "padding-size (#{padding_length}) cannot be larger than packet_length - 1 (#{packet_length})"
      end

      payload = data.byteslice(5, packet_length - padding_length - 1)
      data[0, packet_length + 4] = ""

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
    # @return [String] A binary string, which contains the new packet.
    def self.create(payload, keystore)
      length = ((payload.length + 5) / 8.0).ceil * 8
      padding_length = length - 5 - payload.length

      if padding_length < 4
        length += 8
        padding_length = length - 5 - payload.length
      end

      data = ""
      data += [length - 4, padding_length].pack("NC")
      data += payload
      data += Array.new(padding_length, 0).pack("C*")
    end
  end
end
