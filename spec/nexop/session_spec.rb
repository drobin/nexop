require 'spec_helper'

describe Nexop::Session do
  let(:session) { Nexop::Session.new }

  it "has an empty input-buffer after creation" do
    session.ibuf.should == ""
  end

  it "has an empty output-buffer after creation" do
    session.obuf.should == ""
  end

  context "server_identification" do
    it "is nil after creation of the session" do
      session.server_identification.should be_nil
    end

    it "is assigned after the first tick" do
      session.tick.should be_true
      session.server_identification.should == "SSH-2.0-nexop_#{Nexop::VERSION}"
      session.obuf.should == "SSH-2.0-nexop_#{Nexop::VERSION}\r\n"
    end
  end

  context "client_identification" do
    before(:each) do
      session.tick
      session.obuf.clear
    end

    it "is nil after creation of the session" do
      session.client_identification.should be_nil
    end

    it "skips the assignment when the received identification-string is incomplete" do
      session.ibuf += "foo\r"
      session.tick.should be_true
      session.client_identification.should be_nil
    end

    it "is assigned when the identification-string is complete" do
      session.ibuf += "foo\r\n"
      session.tick.should be_true
      session.client_identification.should == "foo"
    end
  end
end
