require 'spec_helper'

describe Nexop::Message::Ignore do
  let(:msg) { Nexop::Message::Ignore.new }

  it "has a type field" do
    msg.type.should == Nexop::Message::Ignore::SSH_MSG_IGNORE
  end

  it "has a data field" do
    msg.data.should == ""
  end
end
