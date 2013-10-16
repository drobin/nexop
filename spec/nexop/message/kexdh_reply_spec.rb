require 'spec_helper'

describe Nexop::Message::KexdhReply do
  let(:msg) { Nexop::Message::KexdhReply.new }

  it "has a type-field" do
    msg.type.should == Nexop::Message::KexdhReply::SSH_MSG_KEXDH_REPLY
  end

  it "has a k_s field" do
    msg.k_s.should be_nil
  end

  it "has a f field" do
    msg.f.should be_nil
  end

  it "has a sig_h field" do
    msg.sig_h.should be_nil
  end
end
