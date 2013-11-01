require 'spec_helper'

describe Nexop::Handler::Service do
  let(:receiver) { double(:m => nil)}
  let(:handler) { Nexop::Handler::Service.new(receiver.method(:m)) }

  context "services" do
    it "is empty by default" do
      handler.services.should be_empty
    end
  end

  context "add_service" do
    it "registers a new service" do
      service = Nexop::ServiceBase.new("foo")
      handler.add_service(service)
      handler.services.should == [ service ]
    end

    it "cannot add an invalid service" do
      expect{ handler.add_service("xxx") }.to raise_error(ArgumentError)
    end
  end
end
