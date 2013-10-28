require 'spec_helper'

describe Nexop::MacAlgorithm do
  ALL_ALGORITHMS = [
    Nexop::MacAlgorithm::SHA1,
    Nexop::MacAlgorithm::NONE
  ]

  context "supported?" do
    ALL_ALGORITHMS.each do |algorithm|
      it "#{algorithm} is a supported algorithm" do
        Nexop::MacAlgorithm::supported?(algorithm).should be_true
      end
    end

    it "xxx is not a supported algorithm" do
      Nexop::MacAlgorithm::supported?("xxx").should be_false
    end
  end

  context "from_s" do
    ALL_ALGORITHMS.each do |algorithm|
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

  context "name" do
    ALL_ALGORITHMS.each do |algorithm|
      it "returns the name of #{algorithm}" do
        Nexop::MacAlgorithm.from_s(algorithm).name.should == algorithm
      end
    end
  end
end
