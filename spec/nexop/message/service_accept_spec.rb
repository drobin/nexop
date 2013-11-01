require 'spec_helper'

describe Nexop::Message::ServiceAccept do
  let(:msg) { Nexop::Message::ServiceAccept.new }

  it "has a type field" do
    msg.type.should == Nexop::Message::ServiceAccept::SSH_MSG_SERVICE_ACCEPT
  end

  it "has a service_name field" do
    msg.service_name.should be_nil
  end
end
