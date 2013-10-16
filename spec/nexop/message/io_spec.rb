# encoding: utf-8
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

  context "boolean" do
    include_examples "basic IO examples", :boolean

    it "encodes a true-value" do
      Nexop::Message::IO.boolean(:encode, true).should == [ 1 ].pack("C")
    end

    it "encodes a false-value" do
      Nexop::Message::IO.boolean(:encode, false).should == [ 0 ].pack("C")
    end

    it "decodes 0 to false" do
      Nexop::Message::IO.boolean(:decode, [1, 2, 0].pack("C*"), 2).should == [ false, 1 ]
    end

    it "decodes 1 to true" do
      Nexop::Message::IO.boolean(:decode, [1, 2, 1].pack("C*"), 2).should == [ true, 1 ]
    end

    it "decodes non-zero to true" do
      Nexop::Message::IO.boolean(:decode, [1, 2, 3].pack("C*"), 2).should == [ true, 1 ]
    end

    it "cannot decode an empty binary string" do
      expect{ Nexop::Message::IO.boolean(:decode, "", 0) }.to raise_error(TypeError)
    end
  end

  context "name_list" do
    include_examples "basic IO examples", :name_list

    it "encodes an empty list" do
      Nexop::Message::IO.name_list(:encode, []).should == [ 0, 0, 0, 0 ].pack("C*")
    end

    it "encodes a list with one element" do
      Nexop::Message::IO.name_list(:encode, ["foo"]).should == [ 0, 0, 0, 3, 102, 111, 111 ].pack("C*")
    end

    it "encodes an non-empty list" do
      Nexop::Message::IO.name_list(:encode, ["foo", "bar"]).should == [ 0, 0, 0, 7, 102, 111, 111, 44, 98, 97, 114 ].pack("C*")
    end

    it "cannot encode a list with an empty element" do
      expect{ Nexop::Message::IO.name_list(:encode, ["foo", ""]) }.to raise_error(ArgumentError)
    end

    it "cannot encode a list with an entry not encoded in US-ASCII" do
      expect{ Nexop::Message::IO.name_list(:encode, ["foo", "föö"]) }.to raise_error(Encoding::UndefinedConversionError)
    end

    it "decodes an empty list" do
      Nexop::Message::IO.name_list(:decode, [1, 0, 0, 0, 0].pack("C*"), 1).should == [ [], 4 ]
    end

    it "decodes a list with one element" do
      Nexop::Message::IO.name_list(:decode, [ 5, 0, 0, 0, 3, 102, 111, 111 ].pack("C*"), 1).should == [ ["foo"], 7 ]
    end

    it "decodes a non-empty list" do
      Nexop::Message::IO.name_list(:decode, [ 5, 0, 0, 0, 7, 102, 111, 111, 44, 98, 97, 114 ].pack("C*"), 1).should == [ ["foo", "bar"], 11 ]
    end

    it "cannot decode list list with an element not encoded in US-ASCII" do
      expect{ Nexop::Message::IO.name_list(:decode, [ 5, 0, 0, 0, 3, 102, 111, 239 ].pack("C*"), 1) }.to raise_error(Encoding::UndefinedConversionError)
    end

    it "cannot decode a list with an incomplete length-field" do
      expect{ Nexop::Message::IO.name_list(:decode, [ 5, 0, 0, 0 ].pack("C*"), 1) }.to raise_error(ArgumentError)
    end

    it "cannot decode a list with an incomplete list" do
      expect{ Nexop::Message::IO.name_list(:decode, [ 5, 0, 0, 0, 3, 102, 111 ].pack("C*"), 1) }.to raise_error(ArgumentError)
    end
  end

  context "mpint" do
    include_examples "basic IO examples", :mpint

    it "encodes zero" do
      Nexop::Message::IO.mpint(:encode, 0).should == [ 0, 0, 0, 0 ].pack("C*")
    end

    it "encodes 9a378f9b2e332a7" do
      Nexop::Message::IO.mpint(:encode, "9a378f9b2e332a7".to_i(16)).should == [ 0x00, 0x00, 0x00, 0x08, 0x09, 0xa3, 0x78, 0xf9, 0xb2, 0xe3, 0x32, 0xa7 ].pack("C*")
    end

    it "encodes 80" do
      Nexop::Message::IO.mpint(:encode, 0x80).should == [ 0x00, 0x00, 0x00, 0x02, 0x00, 0x80 ].pack("C*")
    end

    it "decodes to zero" do
      Nexop::Message::IO.mpint(:decode, [1, 0, 0, 0, 0].pack("C*"), 1).should == [ 0, 4 ]
    end

    it "decodes to 9a378f9b2e332a7" do
      Nexop::Message::IO.mpint(:decode, [0x01, 0x00, 0x00, 0x00, 0x08, 0x09, 0xa3, 0x78, 0xf9, 0xb2, 0xe3, 0x32, 0xa7].pack("C*"), 1).should == [ "9a378f9b2e332a7".to_i(16), 12 ]
    end

    it "decodes to 80" do
      Nexop::Message::IO.mpint(:decode, [0x01, 0x00, 0x00, 0x00, 0x02, 0x00, 0x80].pack("C*"), 1).should == [ 0x80, 6 ]
    end

    it "cannot decode if the length-field is incomplete" do
      expect{ Nexop::Message::IO.mpint(:decode, [0x01, 0x00, 0x00, 0x00].pack("C*"), 1) }.to raise_error(ArgumentError)
    end

    it "cannot decode if the number-field is incomplete" do
      expect{ Nexop::Message::IO.mpint(:decode, [0x01, 0x00, 0x00, 0x00, 0x02, 0x00].pack("C*"), 1) }.to raise_error(ArgumentError)
    end
  end
end
