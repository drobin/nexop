require 'spec_helper'

describe Nexop::Message::Disconnect do
  let(:msg) { Nexop::Message::Disconnect.new }

  it "has a type field" do
    msg.type.should == Nexop::Message::Disconnect::SSH_MSG_DISCONNECT
  end

  it "has a reason_code field" do
    msg.reason_code.should be_nil
  end

  it "has a description field" do
    msg.description.should == ""
  end

  it "has a language_tag field" do
    msg.language_tag.should == ""
  end
end
