require 'spec_helper'

describe Nexop::Packet do
  let(:keystore) { Nexop::Keystore.new }

  before(:each) { keystore.keys!("abc", 4711) }

  PACKET = [
    0, 0, 0, 12,         # packet_length
    4,                   # padding_length
    1, 2, 3, 4, 5, 6, 7, # payload
    8, 9, 10, 11         # padding
  ]

  [ Nexop::EncryptionAlgorithm::DES, Nexop::EncryptionAlgorithm::NONE ].each do |enc_alg|
    [ Nexop::MacAlgorithm::SHA1, Nexop::MacAlgorithm::NONE ].each do |mac_alg|
      context "parse" do
        let(:payload) { String.new }

        (0..PACKET.length - 1).each do |len|
          it "skips an incomplete packet with the length of #{len} for #{enc_alg}/#{mac_alg}" do
            keystore.algorithms!(:c2s, enc_alg, mac_alg)
            keystore.algorithms!(:s2c, enc_alg, mac_alg)

            data = (len == 0 ? "" : encrypt(PACKET[0..len - 1], keystore))
            data_len = data.length
            Nexop::Packet.parse(data, keystore, 0).should be_nil
            data.length.should == data_len
          end
        end

        it "rejects a packet with an invalid size for #{enc_alg}/#{mac_alg}" do
          keystore.algorithms!(:c2s, enc_alg, mac_alg)
          keystore.algorithms!(:s2c, enc_alg, mac_alg)

          bin = PACKET.clone << 12
          bin[3] = 13
          data = encrypt(bin, keystore)
          data_len = data.length
          expect{ Nexop::Packet.parse(data, keystore, 0) }.to raise_error(ArgumentError)
          data.length.should == data_len
        end

        it "rejects a packet with a padding, which is too small for #{enc_alg}/#{mac_alg}" do
          keystore.algorithms!(:c2s, enc_alg, mac_alg)
          keystore.algorithms!(:s2c, enc_alg, mac_alg)

          bin = PACKET.clone
          bin[3] = 3
          data = encrypt(bin, keystore)
          data_len = data.length
          expect{ Nexop::Packet.parse(data, keystore, 0) }.to raise_error(ArgumentError)
          data.length.should == data_len
        end

        it "rejects a packet with a padding, which is too large for #{enc_alg}/#{mac_alg}" do
          keystore.algorithms!(:c2s, enc_alg, mac_alg)
          keystore.algorithms!(:s2c, enc_alg, mac_alg)

          bin = PACKET.clone
          bin[4] = 12
          data = encrypt(bin, keystore)
          data_len = data.length
          expect{ Nexop::Packet.parse(data, keystore, 0) }.to raise_error(ArgumentError)
          data.length.should == data_len
        end

        it "returns the payload of the packet for #{enc_alg}/#{mac_alg}" do
          keystore.algorithms!(:c2s, enc_alg, mac_alg)
          keystore.algorithms!(:s2c, enc_alg, mac_alg)

          payload = Nexop::Packet.parse(encrypt(PACKET, keystore), keystore, 0)
          payload.unpack("C*").should == [1, 2, 3, 4, 5, 6, 7]
        end

        it "removes the data from the input buffer for #{enc_alg}/#{mac_alg}" do
          keystore.algorithms!(:c2s, enc_alg, mac_alg)
          keystore.algorithms!(:s2c, enc_alg, mac_alg)

          data = encrypt(PACKET, keystore) + "abc"
          Nexop::Packet.parse(data, keystore, 0)
          data.should == "abc"
        end

        it "rejects a packet with an invalid MAC for #{enc_alg}/#{mac_alg}" do
          if mac_alg != Nexop::MacAlgorithm::NONE
            keystore.algorithms!(:c2s, enc_alg, mac_alg)
            keystore.algorithms!(:s2c, enc_alg, mac_alg)

            data = encrypt(PACKET, keystore)
            data[data.length - 1] = "x"
            data_len = data.length
            expect{ Nexop::Packet.parse(data, keystore, 0) }.to raise_error(ArgumentError)
            data.length.should == data_len
          end
        end
      end

      context "create" do
        it "creates a packet with empty payload for #{enc_alg}" do
          keystore.algorithms!(:c2s, enc_alg, Nexop::MacAlgorithm::NONE)
          keystore.algorithms!(:s2c, enc_alg, Nexop::MacAlgorithm::NONE)

          packet = Nexop::Packet.create("", keystore, 0)
          decrypt(packet, keystore).unpack("C*").should == [0, 0, 0, 12, 11, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        end

        it "creates a packet with padding for #{enc_alg}" do
          keystore.algorithms!(:c2s, enc_alg, Nexop::MacAlgorithm::NONE)
          keystore.algorithms!(:s2c, enc_alg, Nexop::MacAlgorithm::NONE)

          packet = Nexop::Packet.create([1, 2, 3, 4, 5, 6].pack("C*"), keystore, 0)
          decrypt(packet, keystore).unpack("C*").should == [0, 0, 0, 12, 5, 1, 2, 3, 4, 5, 6, 0, 0, 0, 0, 0]
        end

        it "creates a packet a a calculated padding >= 4 for #{enc_alg}" do
          keystore.algorithms!(:c2s, enc_alg, Nexop::MacAlgorithm::NONE)
          keystore.algorithms!(:s2c, enc_alg, Nexop::MacAlgorithm::NONE)

          packet = Nexop::Packet.create([1, 2, 3, 4, 5, 6, 7, 8].pack("C*"), keystore, 0)
          decrypt(packet, keystore).unpack("C*").should == [0, 0, 0, 20, 11, 1, 2, 3, 4, 5, 6, 7, 8, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
        end
      end
    end
  end
end
