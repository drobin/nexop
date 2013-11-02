require 'spec_helper'

describe Nexop::Message::Debug do
  let(:msg) { Nexop::Message::Debug.new }

  it "has a type field" do
    msg.type.should == Nexop::Message::Debug::SSH_MSG_DEBUG
  end

  it "has an always_display field" do
    msg.always_display.should be_false
  end

  it "has a message field" do
    msg.message.should be_nil
  end

  it "has a language_tag field" do
    msg.language_tag.should == ""
  end
end
