require 'spec_helper'

describe Nexop::Packet do
  let(:keystore) { Nexop::Keystore.new }

  context "parse" do
    PACKET = [
      0, 0, 0, 12,         # packet_length
      4,                   # padding_length
      1, 2, 3, 4, 5, 6, 7, # payload
      8, 9, 10, 11         # padding
    ]

    let(:payload) { String.new }

    (0..PACKET.length - 1).each do |len|
      it "skips an incomplete packet with the length of #{len}" do
        data = (len == 0 ? [] : PACKET[0..len - 1]).pack("C*")
        Nexop::Packet.parse(data, keystore).should be_nil
        data.length.should == len
      end
    end

    it "rejects a packet with an invalid size" do
      bin = PACKET.clone << 12
      bin[3] = 13
      data = bin.pack("C*")
      expect{ Nexop::Packet.parse(data) }.to raise_error(ArgumentError)
      data.length.should == 17
    end

    it "rejects a packet with a padding, which is too small" do
      bin = PACKET.clone
      bin[3] = 3
      data = bin.pack("C*")
      expect{ Nexop::Packet.parse(data) }.to raise_error(ArgumentError)
      data.length.should == 16
    end

    it "rejects a packet with a padding, which is too large" do
      bin = PACKET.clone
      bin[4] = 12
      data = bin.pack("C*")
      expect{ Nexop::Packet.parse(data, keystore) }.to raise_error(ArgumentError)
      data.length.should == 16
    end

    it "returns the payload of the packet" do
      payload = Nexop::Packet.parse(PACKET.pack("C*"), keystore)
      payload.unpack("C*").should == [1, 2, 3, 4, 5, 6, 7]
    end

    it "removes the data from the input buffer" do
      data = (PACKET.clone << 12 << 13 << 14).pack("C*")
      Nexop::Packet.parse(data, keystore)
      data.unpack("C*").should == [12, 13, 14]
    end
  end

  context "create" do
    it "creates a packet with empty payload" do
      packet = Nexop::Packet.create("", keystore)
      packet.unpack("C*").should == [0, 0, 0, 12, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    end

    it "creates a packet with padding" do
      packet = Nexop::Packet.create([1, 2, 3, 4, 5, 6].pack("C*"), keystore)
      packet.unpack("C*").should == [0, 0, 0, 12, 5, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0]
    end

    it "creates a packet a a calculated padding >= 4" do
      packet = Nexop::Packet.create([1, 2, 3, 4, 5, 6, 7, 8].pack("C*"), keystore)
      packet.unpack("C*").should == [0, 0, 0, 20, 11, 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    end
  end
end
