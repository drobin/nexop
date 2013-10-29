require 'spec_helper'

describe Nexop::EncryptionAlgorithm do
  ENC_ALGORITHMS = [
    Nexop::EncryptionAlgorithm::DES,
    Nexop::EncryptionAlgorithm::NONE
  ]

  context "supported?" do
    ENC_ALGORITHMS.each do |algorithm|
      it "#{algorithm} is a valid algorithm" do
        Nexop::EncryptionAlgorithm.supported?(algorithm).should be_true
      end

      it "xxx is an invalid algorithm" do
        Nexop::EncryptionAlgorithm.supported?("xxx").should be_false
      end
    end
  end

  context "from_s" do
    ENC_ALGORITHMS.each do |algorithm|
      it "creates an instance from #{algorithm}" do
        Nexop::EncryptionAlgorithm.from_s(algorithm).should be_a_kind_of(Nexop::EncryptionAlgorithm)
      end

      it "returns a singleton instance for #{algorithm}" do
        instance = Nexop::EncryptionAlgorithm.from_s(algorithm)
        Nexop::EncryptionAlgorithm.from_s(algorithm).should equal(instance)
      end
    end

    it "cannot create an instance from an invalid algorithm" do
      Nexop::EncryptionAlgorithm.from_s("xxx").should be_nil
    end
  end

  context Nexop::EncryptionAlgorithm::DES do
    let(:algorithm) { Nexop::EncryptionAlgorithm.from_s(Nexop::EncryptionAlgorithm::DES) }

    it "name should be #{Nexop::EncryptionAlgorithm::DES}" do
      algorithm.name.should == Nexop::EncryptionAlgorithm::DES
    end

    it "block_size should be 8" do
      algorithm.block_size.should == 8
    end
  end

  context Nexop::EncryptionAlgorithm::NONE do
    let(:algorithm) { Nexop::EncryptionAlgorithm.from_s(Nexop::EncryptionAlgorithm::NONE) }

    it "name should be #{Nexop::EncryptionAlgorithm::NONE}" do
      algorithm.name.should == Nexop::EncryptionAlgorithm::NONE
    end

    it "block_size should be 8" do
      algorithm.block_size.should == 8
    end
  end
end
