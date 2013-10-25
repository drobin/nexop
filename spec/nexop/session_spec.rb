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

  context "hostkey" do
    it "has no key assigned by default" do
      session.hostkey.should be_nil
    end

    it "can be assigned" do
      session.hostkey = 1
      session.hostkey.should == 1
    end
  end

  context "kex phase" do
    before(:each) { session.instance_variable_set(:@server_identification, "foo") }
    before(:each) { session.instance_variable_set(:@client_identification, "bar") }
    before(:each) { session.instance_variable_set(:@phase, :kex) }

    it "should stay in the kex-phase when the kex-handler returns true" do
      Nexop::Packet.should_receive(:parse).and_return("xxx", nil)
      session.should_receive(:tick_kex).with("xxx").and_return(true)

      session.tick.should be_true
      session.instance_variable_get(:@phase).should == :kex
    end

    it "switches to the finished-phase when the kex-handler returns false" do
      Nexop::Packet.should_receive(:parse).and_return("xxx")
      session.should_receive(:tick_kex).with("xxx").and_return(false)

      session.tick.should be_false
      session.instance_variable_get(:@phase).should == :finished
    end
  end
end
