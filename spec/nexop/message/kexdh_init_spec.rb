require 'spec_helper'

describe Nexop::Message::KexdhInit do
  let(:msg) { Nexop::Message::KexdhInit.new }

  it "has a type field" do
    msg.type.should == Nexop::Message::KexdhInit::SSH_MSG_KEXDH_INIT
  end

  it "has an e field" do
    msg.e.should be_nil
  end
end
