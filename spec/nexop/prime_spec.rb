require 'spec_helper'

describe Nexop::Prime do
  it "has the group1-prime" do
    Nexop::Prime::MODP_GROUP1.should have(1024 / 8).items
  end

  it "has the group14-prime" do
    Nexop::Prime::MODP_GROUP14.should have(2048 / 8).items
  end

  context "to_i" do
    it "creates a number from an array" do
      Nexop::Prime.to_i([1, 2, 3]).should == 66051
    end
  end
end
