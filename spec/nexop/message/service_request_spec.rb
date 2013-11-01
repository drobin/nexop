require 'spec_helper'

describe Nexop::Message::ServiceRequest do
  let(:msg) { Nexop::Message::ServiceRequest.new }

  it "has a type field" do
    msg.type.should == Nexop::Message::ServiceRequest::SSH_MSG_SERVICE_REQUEST
  end

  it "has a service_name field" do
    msg.service_name.should be_nil
  end
end
