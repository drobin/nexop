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
end
