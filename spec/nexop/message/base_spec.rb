require 'spec_helper'

describe Nexop::Message::Base do
  let(:klass) do
    Class.new(Nexop::Message::Base) do
      add_field(:f1, :type => :foo)
      add_field(:f2, :type => :bar, :default => "xxx")
      add_field(:f3, :type => :dingens, :const => 4711)
      add_field(:f4, :type => :bummens) { 666 }
    end
  end

  let(:obj) { klass.new }

  context "metamodel" do
    it "cannot have fields with the same name" do
      expect do
        Class.new(Nexop::Message::Base) do
          add_field(:f1, :type => :xxx)
          add_field(:f1, :type => :xxx)
        end
      end.to raise_error(RuntimeError)
    end

    it "cannot have a field without a type" do
      expect do
        Class.new(Nexop::Message::Base) do
          add_field(:f1)
        end
      end.to raise_error(RuntimeError)
    end

    it "cannot have a constant field which has a default-value" do
      expect do
        Class.new(Nexop::Message::Base) do
          add_field(:f1, :const => 1, :default => 2)
        end
      end.to raise_error(RuntimeError)
    end

    it "cannot have a constant Proc-field which has a default-value" do
      expect do
        Class.new(Nexop::Message::Base) do
          add_field(:f1, :default => 2) { 1 }
        end
      end.to raise_error(RuntimeError)
    end

    it "has some fields" do
      klass.fields.should == [:f1, :f2, :f3, :f4]
    end

    it "has a field" do
      klass.field(:f1).should == { :name => :f1, :type => :foo, :default => nil }
      klass.field("f2").should == { :name => :f2, :type => :bar, :default => "xxx" }
      klass.field(:f3).should == { :name => :f3, :type => :dingens, :const => 4711 }
    end
  end

  context "field" do
    it "is readable" do
      obj.f1.should be_nil
    end

    it "has a default value" do
      obj.f2.should == "xxx"
    end

    it "is writable" do
      obj.f1 = 4711
      obj.f1.should == 4711
    end

    it "will not create a accessor for an unknown field" do
      expect{ obj.xxx }.to raise_error(NoMethodError)
    end
  end

  context "field_get_set" do
    it "returns the value of an existing field" do
      obj.field_get("f1").should be_nil
      obj.field_get(:f2).should == "xxx"
    end

    it "returns the field on a constant Proc-field" do
      obj.field_get(:f4).should == 666
    end

    it "raises an exception when you pass an unknown field" do
      expect{ obj.field_get(:xxx) }.to raise_error(ArgumentError)
    end

    it "can update the value of an exisiting field" do
      obj.field_set(:f1, "blubber")
      obj.f1.should == "blubber"
    end

    it "cannot update the value of an non-existing field" do
      expect{ obj.field_set(:xxx, "xxx") }.to raise_error(ArgumentError)
    end

    it "can update a constant field with the same value" do
      obj.field_set(:f3, 4711)
      obj.f3.should == 4711
    end

    it "cannot update a constant field with another value" do
      expect{ obj.field_set(:f3, 666) }.to raise_error(ArgumentError)
    end
  end

  context "initialize" do
    it "assigns no values to the message" do
      msg = klass.new
      msg.f1.should be_nil
      msg.f2.should == "xxx"
      msg.f3.should == 4711
      msg.f4.should == 666
    end

    it "assigns values to the message" do
      msg = klass.new(:f1 => "111", :f2 => "222")
      msg.f1.should == "111"
      msg.f2.should == "222"
      msg.f3.should == 4711
      msg.f4.should == 666
    end

    it "rejects unknown fields" do
      expect{ klass.new(:xxx => "abc") }.to raise_error(ArgumentError)
    end

    it "cannot change constant fields" do
      expect{ klass.new(:f3 => "xxx") }.to raise_error(ArgumentError)
    end
  end

  context "parse" do
    it "creates a message" do
      Nexop::Message::IO.should_receive(:foo).and_return(["a", 1])
      Nexop::Message::IO.should_receive(:bar).and_return(["b", 1])
      Nexop::Message::IO.should_receive(:dingens).and_return([4711, 1])
      Nexop::Message::IO.should_receive(:bummens).and_return([666, 1])
      obj = klass.parse([1, 2, 3, 4].pack("C*"))
      obj.should be_a_kind_of(klass)
      obj.f1.should == "a"
      obj.f2.should == "b"
      obj.f3.should == 4711
      obj.f4.should == 666
    end

    it "should pass the buffer and the offset to the IO-method" do
      data = [1, 2, 3, 4].pack("C*")
      Nexop::Message::IO.should_receive(:foo).with(:decode, data, 0).and_return(["a", 1])
      Nexop::Message::IO.should_receive(:bar).with(:decode, data, 1).and_return(["b", 1])
      Nexop::Message::IO.should_receive(:dingens).with(:decode, data, 2).and_return([4711, 1])
      Nexop::Message::IO.should_receive(:bummens).with(:decode, data, 3).and_return([666, 1])
      klass.parse(data)
    end

    it "aborts in case of a constant field should be changed" do
      Nexop::Message::IO.should_receive(:foo).and_return(["a", 1])
      Nexop::Message::IO.should_receive(:bar).and_return(["b", 1])
      Nexop::Message::IO.should_receive(:dingens).and_return([666, 1])
      expect{ klass.parse([1, 2, 3].pack("C*")) }.to raise_error(ArgumentError)
    end

    it "aborts in case of a parser-error" do
      Nexop::Message::IO.should_receive(:foo).and_raise(TypeError)
      expect{ klass.parse([1, 2, 3].pack("C*")) }.to raise_error(TypeError)
    end

    it "aborts in case of a data-underflow" do
      Nexop::Message::IO.should_receive(:foo).and_return(["a", 1])
      Nexop::Message::IO.should_receive(:bar).and_return(["b", 1])
      Nexop::Message::IO.should_receive(:dingens).and_return(["c", 1])
      expect{ klass.parse([1, 2, 3, 4].pack("C*")) }.to raise_error(ArgumentError)
    end
  end

  context "serialize" do
    it "serializes a message" do
      Nexop::Message::IO.should_receive(:foo).and_return("a")
      Nexop::Message::IO.should_receive(:bar).and_return("b")
      Nexop::Message::IO.should_receive(:dingens).and_return("c")
      Nexop::Message::IO.should_receive(:bummens).and_return("d")
      obj.serialize.should == "abcd"
    end

    it "should pass the correct arguments to the IO-methods" do
      obj.f1 = "a"
      obj.f2 = "b"
      Nexop::Message::IO.should_receive(:foo).with(:encode, "a").and_return("")
      Nexop::Message::IO.should_receive(:bar).with(:encode, "b").and_return("")
      Nexop::Message::IO.should_receive(:dingens).with(:encode, 4711).and_return("")
      Nexop::Message::IO.should_receive(:bummens).with(:encode, 666).and_return("")
      obj.serialize
    end

    it "aborts serialization in case of a parser-error" do
      Nexop::Message::IO.should_receive(:foo).and_raise(TypeError)
      expect{ obj.serialize }.to raise_error(TypeError)
    end
  end

  context "==" do
    it "fails if the classes are different" do
      obj.should_not == Object.new
    end

    it "fails if the value of a field are different" do
      other = obj.clone
      other.f1 = "xxx"
      obj.should_not == other
    end

    it "succeeds if the values of all fields are the same" do
      obj.should == obj.clone
    end

    it "succeeds if the other object refers to the same object" do
      obj.should == obj
    end
  end
end
