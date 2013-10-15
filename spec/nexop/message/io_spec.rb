require 'spec_helper'

shared_examples "basic IO examples" do |method|
  it "rejects an unsupported operation" do
    expect{ Nexop::Message::IO.send(method, :xxx) }.to raise_error(ArgumentError)
  end

  context "encoder" do
  end

  context "decoder" do
  end
end

describe Nexop::Message::IO do
  context "byte" do
    include_examples "basic IO examples", :byte

    it "can encode a value" do
      Nexop::Message::IO.byte(:encode, 17).should == [17].pack("C")
    end

    it "can decode a string" do
      Nexop::Message::IO.byte(:decode, [1, 2, 3, 4].pack("C*"), 2).should == [3, 1]
    end

    it "cannot decode due to a buffer-overflow" do
      expect{ Nexop::Message::IO.byte(:decode, [1, 2, 3].pack("C*"), 3) }.to raise_error(ArgumentError)
    end
  end
end
