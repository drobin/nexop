module Nexop::Message
  ##
  # The base-class for all concrete SSH messages.
  #
  # Defines a metamodel for concrete messages. The
  # {Nexop::Message::Base#add_field} method is used assign a datafield to the
  # message. So, a message can be read from a binary steam and serialized into
  # a binary form again.
  class Base
    ##
    # Assigns a datafield to
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

    def self.fields
      (@fields || []).map{ |f| f[:name] }
    end

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
