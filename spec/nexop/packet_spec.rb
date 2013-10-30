require 'spec_helper'

describe Nexop::Packet do
  let(:keystore) { Nexop::Keystore.new }

  before(:each) { keystore.keys!("abc", 4711) }

  context "parse" do
    PACKET = [
      0, 0, 0, 12,         # packet_length
      4,                   # padding_length
      1, 2, 3, 4, 5, 6, 7, # payload
      8, 9, 10, 11         # padding
    ]

    let(:payload) { String.new }

    [ Nexop::EncryptionAlgorithm::DES, Nexop::EncryptionAlgorithm::NONE ].each do |algorithm|
      (0..PACKET.length - 1).each do |len|
        it "skips an incomplete packet with the length of #{len} for #{algorithm}" do
          keystore.algorithms!(:c2s, algorithm, Nexop::MacAlgorithm::NONE)
          keystore.algorithms!(:s2c, algorithm, Nexop::MacAlgorithm::NONE)

          data = (len == 0 ? "" : encrypt(PACKET[0..len - 1], keystore))
          Nexop::Packet.parse(data, keystore).should be_nil
          data.length.should == len
        end
      end

      it "rejects a packet with an invalid size" do
        keystore.algorithms!(:c2s, algorithm, Nexop::MacAlgorithm::NONE)
        keystore.algorithms!(:s2c, algorithm, Nexop::MacAlgorithm::NONE)

        bin = PACKET.clone << 12
        bin[3] = 13
        data = encrypt(bin, keystore)
        expect{ Nexop::Packet.parse(data) }.to raise_error(ArgumentError)
        data.length.should == 17
      end

      it "rejects a packet with a padding, which is too small" do
        keystore.algorithms!(:c2s, algorithm, Nexop::MacAlgorithm::NONE)
        keystore.algorithms!(:s2c, algorithm, Nexop::MacAlgorithm::NONE)

        bin = PACKET.clone
        bin[3] = 3
        data = encrypt(bin, keystore)
        expect{ Nexop::Packet.parse(data) }.to raise_error(ArgumentError)
        data.length.should == 16
      end

      it "rejects a packet with a padding, which is too large" do
        keystore.algorithms!(:c2s, algorithm, Nexop::MacAlgorithm::NONE)
        keystore.algorithms!(:s2c, algorithm, Nexop::MacAlgorithm::NONE)

        bin = PACKET.clone
        bin[4] = 12
        data = encrypt(bin, keystore)
        expect{ Nexop::Packet.parse(data, keystore) }.to raise_error(ArgumentError)
        data.length.should == 16
      end

      it "returns the payload of the packet" do
        keystore.algorithms!(:c2s, algorithm, Nexop::MacAlgorithm::NONE)
        keystore.algorithms!(:s2c, algorithm, Nexop::MacAlgorithm::NONE)

        payload = Nexop::Packet.parse(encrypt(PACKET, keystore), keystore)
        payload.unpack("C*").should == [1, 2, 3, 4, 5, 6, 7]
      end

      it "removes the data from the input buffer" do
        keystore.algorithms!(:c2s, algorithm, Nexop::MacAlgorithm::NONE)
        keystore.algorithms!(:s2c, algorithm, Nexop::MacAlgorithm::NONE)

        data = encrypt(PACKET, keystore) + "abc"
        Nexop::Packet.parse(data, keystore)
        data.should == "abc"
      end
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
