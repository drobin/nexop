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

  context "byte_16" do
    include_examples "basic IO examples", :byte_16

    let(:array) { [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16] }

    it "cannot encode a smaller array" do
      expect{ Nexop::Message::IO.byte_16(:encode, array[0, 15]) }.to raise_error(TypeError)
    end

    it "can encode a value" do
      Nexop::Message::IO.byte_16(:encode, array).should == array.pack("C*")
    end

    it "decodes a string" do
      Nexop::Message::IO.byte_16(:decode, [9, 9].concat(array).pack("C*"), 2).should == [array, 16]
    end

    it "cannot decode a smaller string" do
      expect{ Nexop::Message::IO.byte_16(:decode, array[0, 15], 0) }.to raise_error(TypeError)
    end
  end

  context "uint32" do
    include_examples "basic IO examples", :uint32

    it "encodes an int-value" do
      Nexop::Message::IO.uint32(:encode, 4711).should == [4711].pack("N")
    end

    it "decodes a binary string" do
      Nexop::Message::IO.uint32(:decode, [9, 9, 0, 0, 18, 103].pack("C*"), 2).should == [4711, 4]
    end

    it "cannot decode a smaller binary string" do
      expect{ Nexop::Message::IO.uint32(:decode, [9, 9, 0, 0, 18].pack("C*"), 2) }.to raise_error(TypeError)
    end
  end
end
