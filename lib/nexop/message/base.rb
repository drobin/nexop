require 'nexop/message/io'

module Nexop::Message
  ##
  # The base-class for all concrete SSH messages.
  #
  # Defines a metamodel for concrete messages. The {add_field} method is used
  # to assign a datafield to the message. So, a message can be read from a
  # binary steam and serialized into a binary form again.
  class Base
    ##
    # Assigns a datafield to the message-class.
    #
    # All {add_field}-assignments defines the meta-model of the message.
    # Encoding and decoding operations are based on the metamodel of the class.
    # The order of the fields is defines by the order of the
    # {add_field}-invocations.
    #
    # `name` defines an arbitrary name of the field. For each field-`name` a
    # getter and setter are created.
    #
    # You have to specify the datatype of the field with the `:type`-option.
    # Check {Nexop::Message::IO} for a list of supported datatypes.
    #
    # When you pass an `:default`-option, then you can specify a default-value
    # which is initial returned.
    #
    # If the `:const`-option is passed to field-declaration, then you specify a
    # constant value for the field, which cannot be changed from outside. Only
    # one of `:default` and `:const` is allowed. You can assign a value of a
    # constant field, but the new value must equals to the value specified with
    # the `:const`-option. The `==` operator is used for comparison.
    #
    # Passing a `blk` to the method has the same affect than passing a
    # `Proc`-instance to the `:const`-option: The field becomes constant and
    # the block is evaluated everytime the field is {#field_get accessed}.
    #
    # Examples:
    #
    #     class MyMessage < Nexop::Message::Base
    #       attr_accessor :num
    #
    #       # Defines a constant field with the name "type" of type "uint8" with the value `5`
    #       add_field :type, type: :uint8, const: 5
    #
    #       # Defines a field with the name "length" of type "uint32" and a default-value of 45
    #       add_field :length, type: :uint32, default: 45
    #
    #       # Defines a constant field, where a block is evaluated
    #       add_field(:name, type: :string) do |msg|
    #         msg.num && msg.num.odd? ? "odd number" : "even number"
    #       end
    #     end
    def self.add_field(name, options = {}, &blk)
      raise "#{name}: already assigned" if fields.include?(name)
      raise "#{name}: no datatype available" if options[:type].nil?
      raise "#{name}: cannot have default and const" if options.key?(:default) && options.key?(:const)

      @fields ||= []


      options[:const] = blk if blk

      if !options.key?(:const)
        @fields << { :name => name.to_sym, :type => options[:type].to_sym, :default => options[:default] }
      else
        @fields << { :name => name.to_sym, :type => options[:type].to_sym, :const => options[:const] }
      end
    end

    def method_missing(method, *args)
      field_name = method.to_s
      field_name = field_name[0..-2] if field_name.end_with?("=")
      super if self.class.field(field_name).nil?

      if method.to_s.end_with?("=")
        self.class.class_eval <<-EOF
        def #{method}(val)
          self.field_set("#{field_name}", val)
        end
        EOF
      else
        self.class.class_eval <<-EOF
        def #{method}
          field_get("#{field_name}")
        end
        EOF
      end

      send(method, *args)
    end

    ##
    # Returns a list with the name of all assigned {add_field fields}.
    #
    # @return [Array] The names of all assigned fields
    def self.fields
      (@fields || []).map{ |f| f[:name] }
    end

    ##
    # Returns the metadata of the field with the given `name`.
    #
    # @param name [String] The name of the requested field
    # @return [Hash] Meta-data assigned to the field with the
    #         {add_field}-invocation. If no such field exists, `nil` is
    #         returned.
    def self.field(name)
      (@fields || []).select{ |f| f[:name] == name.to_sym }.first
    end

    ##
    # Returns the value of the field with the name `name`.
    #
    # @param name [Symbol] Name of the field
    # @return The value of the field
    # @raise [ArgumentError] if the field `name` does not exist
    def field_get(name)
      meta = self.class.field(name.to_sym)
      raise ArgumentError, "#{name}: no such field" if meta.nil?

      if meta.key?(:const)
        meta[:const].respond_to?(:call) ? meta[:const].call(self) : meta[:const]
      elsif self.instance_variable_defined?("@_#{name}")
        self.instance_variable_get("@_#{name}")
      else
        meta = self.class.field("#{name}".to_sym)
        meta[:default]
      end
    end

    ##
    # Updates the value of the field with the name `name`.
    #
    # If you try to update a constant field, then the new `value` is only
    # accepted, when the already assiged value equals the new `value`, The `==`
    # operator is used for comparison.
    #
    # @param name [Symbol] The name of the field
    # @param value The new value
    # @raise [ArgumentError]
    #        - if the field `name` does not exist
    #        - if you try to change the value of a constant field
    def field_set(name, value)
      meta = self.class.field(name.to_sym)
      raise ArgumentError, "#{name}: no such field" if meta.nil?

      if meta.key?(:const)
        if self.field_get(name) != value
          raise ArgumentError, "#{name}: cannot change constant value"
        end
      else
        self.instance_variable_set("@_#{name}", value)
      end
    end

    ##
    # Parses the given binary string `data` and creates the related message.
    #
    # @param data [String] A binary string contains the raw data of the
    #             message.
    # @return [Base] The requested message, where all the fields are updated
    #         with the information from the input-buffer.
    # @raise [TypeError] if a value of one of the fields could not be created
    # @raise [ArgumentError] if not the whole `data`-buffer could be parsed.
    #        There are still data left in the buffer.
    def self.parse(data)
      msg = self.new

      bytes = fields.inject(0) do |a, e|
        meta = field(e)
        val, nbytes = Nexop::Message::IO.send(meta[:type], :decode, data, a)
        msg.field_set(meta[:name], val)
        a + nbytes
      end

      raise ArgumentError, "bffer underflow" if bytes < data.size

      msg
    end

    ##
    # Serializes the message into a raw-data representation.
    #
    # The resulting data can be assigned to a packet.
    #
    # @return [String] A binary string represents the encoded message
    # @raise [TypeError] if the value of one of the fields could not be encoded
    def serialize
      self.class.fields.inject("") do |a, e|
        meta = self.class.field(e)
        a += Nexop::Message::IO.send(meta[:type], :encode, self.field_get(e))
      end
    end

    ##
    # Compares a message with another one.
    #
    # Two messages are equal, when
    #
    # 1. They refer to the same class (aka have the same metamodel).
    # 2. All fields have the same values (where the `==` operator is used for
    #    comparison)
    #
    # @param other [Object] The object to compare with
    # @return [Boolean] If the two objects refers to the same message, then
    #         `true` is returned, `false` otherwise.
    def == (other)
      return true if self.equal?(other)
      return false if self.class != other.class
      self.class.fields.all? { |f| self.field_get(f) == other.field_get(f) }
    end
  end
end
