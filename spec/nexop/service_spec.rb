require 'spec_helper'

describe Nexop::ServiceBase do
  it "has a name" do
    Nexop::ServiceBase.new("foo").name.should == "foo"
  end

  it "tick is not implemented" do
    expect{ Nexop::ServiceBase.new("foo").tick(nil) }.to raise_error(NotImplementedError)
  end
end
