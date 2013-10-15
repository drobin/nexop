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
    def self.byte(op, *args)
      case op
      when :encode then encode_byte(*args)
      when :decode then decode_byte(*args)
      else raise ArgumentError, "unsupported operation: #{op}"
      end
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
  end
end
