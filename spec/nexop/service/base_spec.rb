require 'spec_helper'

describe Nexop::Service::Base do
  let(:service) { Nexop::Service::Base.new("foo") }

  it "has a name" do
    service.name.should == "foo"
  end

  context "finished" do
    it "is false by default" do
      service.should_not be_finished
    end

    it "can be changed" do
      service.send(:make_finish)
      service.should be_finished
    end
  end

  context "tick" do
    it "must be implemented" do
      expect{ service.tick(nil) }.to raise_error(NotImplementedError)
    end
  end
end
