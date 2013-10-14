require 'spec_helper'

describe Nexop::Message::Base do
  let(:klass) do
    Class.new(Nexop::Message::Base) do
      add_field(:f1, :type => :foo)
      add_field(:f2, :type => :bar, :default => "xxx")
      add_field(:f3, :type => :dingens)
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

    it "has some fields" do
      klass.fields.should == [:f1, :f2, :f3]
    end

    it "has a field" do
      klass.field(:f1).should == { :name => :f1, :type => :foo, :default => nil }
      klass.field("f2").should == { :name => :f2, :type => :bar, :default => "xxx" }
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
end
