require 'spec_helper'

describe Nexop::MacAlgorithm do
  it "SHA1 is a supported algorithm" do
    Nexop::MacAlgorithm::supported?(Nexop::MacAlgorithm::SHA1).should be_true
  end

  it "NONE is a supported algorithm" do
    Nexop::MacAlgorithm::supported?(Nexop::MacAlgorithm::NONE).should be_true
  end

  it "xxx is not a supported algorithm" do
    Nexop::MacAlgorithm::supported?("xxx").should be_false
  end
end
