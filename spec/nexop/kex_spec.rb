require 'spec_helper'

describe Nexop::Kex do
  let(:klass) { Class.new { |c| c.send :include, Nexop::Kex } }
  let(:kex) { klass.new }

  context "kex_init" do
    it "has a message received from the client" do
      kex.kex_init(:c2s).should be_nil
    end

    it "has a message send by the server" do
      msg = kex.kex_init(:s2c)
      msg.should be_an_instance_of(Nexop::Message::KexInit)
      msg.type.should == Nexop::Message::KexInit::SSH_MSG_KEXINIT
      msg.cookie.should == Array.new(16, 0)
      msg.kex_algorithms.should == [ "diffie-hellman-group14-sha1", "diffie-hellman-group1-sha1" ]
      msg.server_host_key_algorithms.should == [ "ssh-rsa" ]
      msg.encryption_algorithms_client_to_server.should == [ "3des-cbc" ]
      msg.encryption_algorithms_server_to_client.should == [ "3des-cbc" ]
      msg.mac_algorithms_client_to_server.should == [ "hmac-sha1" ]
      msg.mac_algorithms_server_to_client.should == [ "hmac-sha1" ]
      msg.compression_algorithms_client_to_server.should == [ "none" ]
      msg.compression_algorithms_server_to_client.should == [ "none" ]
      msg.languages_client_to_server.should be_empty
      msg.languages_server_to_client.should be_empty
      msg.first_kex_packet_follows.should be_false
      msg.reserved.should == 0
    end

    it "has only messages from server and client" do
      expect{ kex.kex_init(:xxx) }.to raise_error(ArgumentError)
    end
  end

  context "receive_kex_init" do
    it "assigns the message received from the client" do
      msg = Nexop::Message::KexInit.new
      kex.receive_kex_init(msg)
      kex.kex_init(:c2s).should equal(msg)
    end
  end
end
