require 'spec_helper'

describe Nexop::EncryptionAlgorithm do
  ALL_ALGORITHMS = [
    Nexop::EncryptionAlgorithm::DES,
    Nexop::EncryptionAlgorithm::NONE
  ]

  context "supported?" do
    ALL_ALGORITHMS.each do |algorithm|
      it "#{algorithm} is a valid algorithm" do
        Nexop::EncryptionAlgorithm.supported?(algorithm).should be_true
      end

      it "xxx is an invalid algorithm" do
        Nexop::EncryptionAlgorithm.supported?("xxx").should be_false
      end
    end
  end

  context "from_s" do
    ALL_ALGORITHMS.each do |algorithm|
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

  context "name" do
    ALL_ALGORITHMS.each do |algorithm|
      it "returns the name of #{algorithm}" do
        Nexop::EncryptionAlgorithm.from_s(algorithm).name.should == algorithm
      end
    end
  end
end
