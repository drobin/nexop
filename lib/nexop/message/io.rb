module Nexop::Message
  ##
  # Datatype conversions used by {Base}.
  #
  # {http://tools.ietf.org/html/rfc4251#section-5 Section 5 of RFC 4251}
  # defines datatypes used by the SSH protocol stack. The class defines
  # methods to parse raw-data into the a natual representation
  # (and vice versa).
  #
  # Each method of the class represents a datatype, which can be used in
  # {Base.add_field} as a datatype.
  #
  # Depending on the operation, the method should perform, the following
  # arguments are passed to the methods:
  #
  # ## Encoding: A concrete message is serialized into a raw representation
  #
  # The operation is performed by {Base#serialize}.
  #
  # The arguments are:
  #
  # 1. `:encode` The symbol denotes, that the encoding operation should be
  #    performed.
  # 2. `value` The value which should be serialized
  #
  # The return-value should be a binary string, which contains the encoded
  # value. If the value couldn't be converted a `TypeError` should be raised.
  #
  # ## Decoding: A binary stream should be converted into a {Base}-instance
  #
  # The operation is performed by {Base.parse}.
  #
  # The arguments are:
  #
  # 1. `:decode` The symbol denotes, that the decoding-operation should be
  #    performed.
  # 2. `data` The binary representation of the message
  # 3. `offset` The offset inside `data`, where the datatype is located. Any
  #    preceding data should be ignored.
  #
  # The return-value of the operation should be an array with two elements: the
  # first contains the resulting object and the second one the number of bytes
  # consumed from the `data`-buffer. If the buffer couldn't be converted a
  # `TypeError` should be raised.
  #
  # @see http://tools.ietf.org/html/rfc4251#section-5
  class IO
    ##
    # List of available conversions.
    # All the names defined here can be used as a datatype in {Base.add_field}.
    CONVERSIONS = [
      :byte,
      :bytes,
      :byte_16,
      :uint32,
      :boolean,
      :name_list,
      :mpint,
      :string
    ]

    CONVERSIONS.each do |op|
      self.class_eval <<-EOF
      def self.#{op}(op, *args)
        case op
        when :encode then encode_#{op}(*args)
        when :decode then decode_#{op}(*args)
        else raise ArgumentError, "unsupported operation: #{op}"
        end
      end
      EOF
    end

    private

    def self.encode_byte(value)
      [ value ].pack("C")
    end

    def self.decode_byte(data, offset)
      if offset < data.length
        [data.unpack("@#{offset}C").first, 1]
      else
        raise ArgumentError, "buffer-overflow, length = #{data.length}, offset = #{offset}"
      end
    end

    def self.encode_bytes(value)
      val = if value.is_a?(String)
        value.unpack("C*")
      else
        value
      end

      val.unshift(val.size).pack("NC*")
    end

    def self.decode_bytes(data, offset)
      length = data.unpack("@#{offset}N").first

      if length.nil? || data.length - offset < length + 4
        raise ArgumentError, "data too small, buffer-size: #{data.size}, offset: #{offset}, length: #{length}"
      end

      [ data[offset + 4, length], length + 4 ]
    end

    def self.encode_byte_16(value)
      if value.size == 16
        value.pack("C*")
      else
        raise TypeError, "invalid array-size: #{value.size}"
      end
    end

    def self.decode_byte_16(data, offset)
      if data.size - offset >= 16
        [data.unpack("@#{offset}C16"), 16]
      else
        raise TypeError, "data too small, length: #{data.size}, offset: #{offset}"
      end
    end

    def self.encode_uint32(value)
      [ value ].pack("N")
    end

    def self.decode_uint32(data, offset)
      if data.length - offset >= 4
        data.unpack("@#{offset}N") << 4
      else
        raise TypeError, "data too small, length: #{data.size}, offset: #{offset}"
      end
    end

    def self.encode_boolean(value)
      [ value ? 1 : 0 ].pack("C")
    end

    def self.decode_boolean(data, offset)
      if data.size - offset >= 1
        [ (data.unpack("@#{offset}C").first == 0) ? false : true, 1 ]
      else
        raise TypeError, "data too small, length: #{data.size}, offset: #{offset}"
      end
    end

    def self.encode_name_list(value)
      if value.any?{ |elem| elem.empty?  }
        raise ArgumentError, "empty list-elements cannot be encoded"
      end

      list = value.join(",").encode("US-ASCII").bytes.to_a
      [ list.size ].concat(list).pack("NC*")
    end

    def self.decode_name_list(data, offset)
      length = data.unpack("@#{offset}N").first

      if length.nil? || data.length - offset < length + 4
        raise ArgumentError, "data too small, length: #{data.size}, offset: #{offset}"
      end

      list = data.unpack("@#{offset + 4}Z#{length}").first.encode("US-ASCII")
      [ list.split(","), length + 4 ]
    end

    def self.encode_mpint(value)
      return [ 0 ].pack("N") if value == 0

      msb_set = value.to_s(2).size  % 8 == 0
      str = value.to_s(16)

      bytes = if str.size % 2 != 0
        first = str[0]
        str[1..-1].scan(/.{2}/).map{ |n| n.to_i(16) }.unshift(first.to_i(16))
      else
        str.scan(/.{2}/).map{ |n| n.to_i(16) }
      end

      bytes.unshift(0) if msb_set
      bytes.unshift(bytes.size).pack("NC*")
    end

    def self.decode_mpint(data, offset)
      length = data.unpack("@#{offset}N").first

      if length.nil? || data.length - offset < length + 4
        raise ArgumentError, "data too small, buffer-size: #{data.size}, offset: #{offset}, length: #{length}"
      end

      num = data.unpack("@#{offset + 4}C#{length}").inject(0) do |a, e|
        a <<= 8
        a |= e
      end

      [ num, length + 4 ]
    end

    def self.encode_string(value)
      bytes = value.bytes.to_a
      bytes.unshift(bytes.size).pack("NC*")
    end

    def self.decode_string(data, offset)
      length = data.unpack("@#{offset}N").first

      if length.nil? || data.length - offset < length + 4
        raise ArgumentError, "data too small, buffer-size: #{data.size}, offset: #{offset}, length: #{length}"
      end

      [ data[offset + 4, length].force_encoding("UTF-8"), length + 4 ]
    end
  end
end
