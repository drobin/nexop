require 'spec_helper'

describe Nexop::MacAlgorithm do
  MAC_ALGORITHMS = [
    Nexop::MacAlgorithm::SHA1,
    Nexop::MacAlgorithm::NONE
  ]

  context "supported?" do
    MAC_ALGORITHMS.each do |algorithm|
      it "#{algorithm} is a supported algorithm" do
        Nexop::MacAlgorithm::supported?(algorithm).should be_true
      end
    end

    it "xxx is not a supported algorithm" do
      Nexop::MacAlgorithm::supported?("xxx").should be_false
    end
  end

  context "from_s" do
    MAC_ALGORITHMS.each do |algorithm|
      it "creates an instance from #{algorithm}" do
        Nexop::MacAlgorithm.from_s(algorithm).should be_a_kind_of(Nexop::MacAlgorithm)
      end

      it "returns a singleton instance for #{algorithm}" do
        instance = Nexop::MacAlgorithm.from_s(algorithm)
        Nexop::MacAlgorithm.from_s(algorithm).should equal(instance)
      end
    end

    it "cannot create an instance from an invalid algorithm" do
      Nexop::MacAlgorithm.from_s("xxx").should be_nil
    end
  end

  context Nexop::MacAlgorithm::SHA1 do
    let(:algorithm) { Nexop::MacAlgorithm.from_s(Nexop::MacAlgorithm::SHA1) }

    it "name should be #{Nexop::MacAlgorithm::SHA1}" do
      algorithm.name.should == Nexop::MacAlgorithm::SHA1
    end

    it "digest_spec should be sha1" do
      algorithm.digest_spec.should == "sha1"
    end

    it "key_length should be 20" do
      algorithm.key_length.should == 20
    end

    it "digest_length should be 20" do
      algorithm.digest_length.should == 20
    end
  end

  context Nexop::MacAlgorithm::NONE do
    let(:algorithm) { Nexop::MacAlgorithm.from_s(Nexop::MacAlgorithm::NONE) }

    it "name should be #{Nexop::MacAlgorithm::NONE}" do
      algorithm.name.should == Nexop::MacAlgorithm::NONE
    end

    it "digest_spec should be nil" do
      algorithm.digest_spec.should be_nil
    end

    it "key_length should be 0" do
      algorithm.key_length.should == 0
    end

    it "digest_length should be 0" do
      algorithm.digest_length.should == 0
    end
  end
end
