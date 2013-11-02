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

  context "keystore" do
    it "is assigned by default" do
      session.keystore.should be_a_kind_of(Nexop::Keystore)
    end
  end

  context "kex" do
    it "is assigned by default" do
      session.kex.should be_a_kind_of(Nexop::Handler::Kex)
    end
  end

  context "service" do
    it "is assigned by default" do
      session.service.should be_a_kind_of(Nexop::Handler::Service)
    end
  end

  context "tick" do
    before(:each) { session.instance_variable_set(:@server_identification, "foo") }
    before(:each) { session.instance_variable_set(:@client_identification, "bar") }

    it "returns false if a SessionError was generated" do
      Nexop::Packet.should_receive(:parse).and_raise(Nexop::SessionError.new)
      session.should_receive(:message_write).with(an_instance_of(Nexop::Message::Disconnect))
      session.tick.should be_false
    end
  end

  context "kex phase" do
    before(:each) { session.instance_variable_set(:@server_identification, "foo") }
    before(:each) { session.instance_variable_set(:@client_identification, "bar") }
    before(:each) { session.instance_variable_set(:@phase, :kex) }

    it "should stay in the kex-phase when the kex-handler returns true" do
      Nexop::Packet.should_receive(:parse).and_return("xxx", nil)
      session.kex.should_receive(:tick).with("xxx").and_return(true)

      session.tick.should be_true
      session.instance_variable_get(:@phase).should == :kex
    end

    it "switches to the service-phase when the kex-handler returns false" do
      Nexop::Packet.should_receive(:parse).and_return("xxx", nil)
      session.kex.should_receive(:tick).with("xxx").and_return(false)

      session.tick.should be_true
      session.instance_variable_get(:@phase).should == :service
    end

    it "prepares the kex-handler" do
      Nexop::Packet.should_receive(:parse).and_return("xxx", nil)
      session.kex.should_receive(:tick).with("xxx").and_return(true)
      session.kex.should_receive(:prepare).with(session.hostkey, "bar", "foo")
      session.tick
    end
  end

  context "service phase" do
    before(:each) { session.instance_variable_set(:@server_identification, "foo") }
    before(:each) { session.instance_variable_set(:@client_identification, "bar") }
    before(:each) { session.instance_variable_set(:@phase, :service) }

    it "switches to the finished-phase when the service-handler returns false" do
      Nexop::Packet.should_receive(:parse).and_return("xxx")
      session.service.should_receive(:tick).with("xxx").and_return(false)

      session.tick.should be_false
      session.instance_variable_get(:@phase).should == :finished
    end
  end
end
