require 'spec_helper'

describe Nexop::Message::NewKeys do
  let(:message) { Nexop::Message::NewKeys.new }

  it "has a type" do
    message.type.should == Nexop::Message::NewKeys::SSH_MSG_NEWKEYS
  end
end
