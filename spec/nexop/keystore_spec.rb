require 'spec_helper'

describe Nexop::Keystore do
  let(:keystore) { Nexop::Keystore.new }

  context "encryption_algorithm" do
    [ :c2s, :s2c ].each do |direction|
      it "is NONE by default for #{direction}" do
        keystore.encryption_algorithm(direction).should == Nexop::EncryptionAlgorithm::NONE
      end
    end

    it "only accepts :c2s and :s2c" do
      expect{ keystore.encryption_algorithm(:xxx) }.to raise_error(ArgumentError)
    end
  end

  context "mac_algorithm" do
    [ :c2s, :s2c ].each do |direction|
      it "is NONE by default for #{direction}" do
        keystore.mac_algorithm(direction).should == Nexop::MacAlgorithm::NONE
      end
    end

    it "only accepts :c2s and :s2c" do
      expect{ keystore.mac_algorithm(:xxx) }.to raise_error(ArgumentError)
    end
  end

  context "exchange_hash" do
    it "is nil be default" do
      keystore.exchange_hash.should be_nil
    end
  end

  context "session_id" do
    it "is nil by default" do
      keystore.session_id.should be_nil
    end
  end

  context "shared_secret" do
    it "is nil by default" do
      keystore.shared_secret.should be_nil
    end
  end

  context "algorithms!" do
    [ :c2s, :s2c ].each do |direction|
      it "updates the algorithms for #{direction}" do
        keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::SHA1)
        keystore.encryption_algorithm(direction).should == Nexop::EncryptionAlgorithm::DES
        keystore.mac_algorithm(direction).should == Nexop::MacAlgorithm::SHA1
      end

      it "rejects an unsupported encryption algorithm for #{direction}" do
        expect{ keystore.algorithms!(direction, "xxx", Nexop::MacAlgorithm::SHA1) }.to raise_error(ArgumentError)
      end

      it "rejects an unsupported mac algorithm for #{direction}" do
        expect{ keystore.algorithms!(direction, Nexop::EncryptionAlgorithm::DES, "xxx") }.to raise_error(ArgumentError)
      end
    end

    it "only accepts :c2s and :s2c" do
      expect{ keystore.algorithms!(:xxx, Nexop::EncryptionAlgorithm::DES, Nexop::MacAlgorithm::SHA1) }.to raise_error(ArgumentError)
    end
  end
end
