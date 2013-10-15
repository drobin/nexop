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
    # Examples:
    #
    #     class MyMessage < Nexop::Message::Base
    #       # Defines a field with the name "type" of type "uint8"
    #       add_field :type, type: :uint8
    #
    #       # Defines a field with the name "length" of type "uint32" and a default-value of 45
    #       add_field :length, type: :uint32, default: 45
    #     end
    def self.add_field(name, options = {})
      raise "#{name}: already assigned" if fields.include?(name)
      raise "#{name}: no datatype available" if options[:type].nil?

      @fields ||= []
      @fields << { :name => name.to_sym, :type => options[:type].to_sym, :default => options[:default] }
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
      raise ArgumentError, "no such field: #{name}" unless self.class.fields.include?(name.to_sym)
      if self.instance_variable_defined?("@_#{name}")
        self.instance_variable_get("@_#{name}")
      else
        meta = self.class.field("#{name}".to_sym)
        meta[:default]
      end
    end

    ##
    # Updates the value of the field with the name `name`.
    #
    # @param name [Symbol] The name of the field
    # @param value The new value
    # @raise [ArgumentError] if the field `name` does not exist
    def field_set(name, value)
      raise ArgumentError, "no such field: #{name}" unless self.class.fields.include?(name.to_sym)
      self.instance_variable_set("@_#{name}", value)
    end
  end
end
