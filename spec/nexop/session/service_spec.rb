require 'spec_helper'

describe Nexop::Handler::Service do
  let(:receiver) { double(:m => nil)}
  let(:handler) { Nexop::Handler::Service.new(receiver.method(:m)) }

  context "services" do
    it "is empty by default" do
      handler.services.should be_empty
    end
  end

  context "current_service" do
    it "is nil by default" do
      handler.current_service.should be_nil
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

  context "tick" do
    context "service is available" do
      let(:service) { Nexop::ServiceBase.new("foo") }
      let(:request) { Nexop::Message::ServiceRequest.new(:service_name => "foo") }
      let(:response) { Nexop::Message::ServiceAccept.new(:service_name => "foo") }
      before(:each) { handler.add_service(service) }

      it "receives a ServiceRequest and answers with a ServiceAccept" do
        receiver.should_receive(:m).with(response)
        handler.tick(request.serialize).should be_true
      end

      it "updates the current_service" do
        handler.tick(request.serialize).should be_true
        handler.current_service.should equal(service)
      end
    end

    context "service is not available" do
      let(:request) { Nexop::Message::ServiceRequest.new(:service_name => "foo") }

      it "receives a ServiceRequest and raises a DisconnectError" do
        expect{ handler.tick(request.serialize) }.to raise_error(Nexop::DisconnectError)
      end

      it "does not update the current_service" do
        expect{ handler.tick(request.serialize) }.to raise_error(Nexop::DisconnectError)
        handler.current_service.should be_nil
      end
    end
  end
end
