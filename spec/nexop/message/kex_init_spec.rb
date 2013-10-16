require 'spec_helper'

describe Nexop::Message::KexInit do
  let(:msg) { Nexop::Message::KexInit.new }

  it "has a type field" do
    msg.type.should == Nexop::Message::KexInit::SSH_MSG_KEXINIT
  end

  it "has a cookie field" do
    msg.cookie.should == Array.new(16, 0)
  end

  it "has a kex_algorithms field" do
    msg.kex_algorithms.should be_empty
  end

  it "has a server_host_key_algorithms field" do
    msg.server_host_key_algorithms.should be_empty
  end

  it "has a encryption_algorithms_client_to_server field" do
    msg.encryption_algorithms_client_to_server.should be_empty
  end

  it "has a encryption_algorithms_server_to_client field" do
    msg.encryption_algorithms_server_to_client.should be_empty
  end

  it "has a mac_algorithms_client_to_server field" do
    msg.mac_algorithms_client_to_server.should be_empty
  end

  it "has a mac_algorithms_server_to_client field" do
    msg.mac_algorithms_server_to_client.should be_empty
  end

  it "has a compression_algorithms_client_to_server field" do
    msg.compression_algorithms_client_to_server.should be_empty
  end

  it "has a compression_algorithms_server_to_client field" do
    msg.compression_algorithms_server_to_client.should be_empty
  end

  it "has a languages_client_to_server field" do
    msg.languages_client_to_server.should be_empty
  end

  it "has a languages_server_to_client field" do
    msg.languages_server_to_client.should be_empty
  end

  it "has a first_kex_packet_follows field" do
    msg.first_kex_packet_follows.should be_nil
  end

  it "has a reserved field" do
    msg.reserved.should == 0
  end

  context "serialize" do
    it "a new object" do
      msg.serialize.unpack("C*").should == [
        Nexop::Message::KexInit::SSH_MSG_KEXINIT, # type
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, # cookie
        0, 0, 0, 0, # kex_algorithms
        0, 0, 0, 0, # server_host_key_algorithms
        0, 0, 0, 0, # encryption_algorithms_client_to_server
        0, 0, 0, 0, # encryption_algorithms_server_to_client
        0, 0, 0, 0, # mac_algorithms_client_to_server
        0, 0, 0, 0, # mac_algorithms_server_to_client
        0, 0, 0, 0, # compression_algorithms_client_to_server
        0, 0, 0, 0, # compression_algorithms_server_to_client
        0, 0, 0, 0, # languages_client_to_server
        0, 0, 0, 0, # languages_server_to_client
        0, # first_kex_packet_follows
        0, 0, 0, 0 # 0 (reserved for future extension)
      ]
    end

    it "an object with some data assigned" do
      msg.cookie = Array.new(16, 5)
      msg.kex_algorithms = [ "a", "b" ]
      msg.server_host_key_algorithms = [ "c", "d" ]
      msg.encryption_algorithms_client_to_server = [ "e", "f" ]
      msg.encryption_algorithms_server_to_client = [ "g", "h" ]
      msg.mac_algorithms_client_to_server = [ "i", "j" ]
      msg.mac_algorithms_server_to_client = [ "k", "l" ]
      msg.compression_algorithms_client_to_server = [ "m", "n" ]
      msg.compression_algorithms_server_to_client = [ "o", "p" ]
      msg.languages_client_to_server = [ "q", "r" ]
      msg.languages_server_to_client = [ "s", "t" ]

      msg.serialize.unpack("C*").should == [
        Nexop::Message::KexInit::SSH_MSG_KEXINIT, # type
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, # cookie
        0, 0, 0, 3, 97, 44, 98, # kex_algorithms
        0, 0, 0, 3, 99, 44, 100, # server_host_key_algorithms
        0, 0, 0, 3, 101, 44, 102, # encryption_algorithms_client_to_server
        0, 0, 0, 3, 103, 44, 104, # encryption_algorithms_server_to_client
        0, 0, 0, 3, 105, 44, 106, # mac_algorithms_client_to_server
        0, 0, 0, 3, 107, 44, 108, # mac_algorithms_server_to_client
        0, 0, 0, 3, 109, 44, 110, # compression_algorithms_client_to_server
        0, 0, 0, 3, 111, 44, 112, # compression_algorithms_server_to_client
        0, 0, 0, 3, 113, 44, 114, # languages_client_to_server
        0, 0, 0, 3, 115, 44, 116, # languages_server_to_client
        0, # first_kex_packet_follows
        0, 0, 0, 0 # 0 (reserved for future extension)
      ]
    end
  end

  context "parse" do
    it "an empty object" do
      payload = [
        Nexop::Message::KexInit::SSH_MSG_KEXINIT, # type
        0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, # cookie
        0, 0, 0, 0, # kex_algorithms
        0, 0, 0, 0, # server_host_key_algorithms
        0, 0, 0, 0, # encryption_algorithms_client_to_server
        0, 0, 0, 0, # encryption_algorithms_server_to_client
        0, 0, 0, 0, # mac_algorithms_client_to_server
        0, 0, 0, 0, # mac_algorithms_server_to_client
        0, 0, 0, 0, # compression_algorithms_client_to_server
        0, 0, 0, 0, # compression_algorithms_server_to_client
        0, 0, 0, 0, # languages_client_to_server
        0, 0, 0, 0, # languages_server_to_client
        0, # first_kex_packet_follows
        0, 0, 0, 0 # 0 (reserved for future extension)
      ].pack("C*")
      msg = Nexop::Message::KexInit.parse(payload)

      msg.type.should == Nexop::Message::KexInit::SSH_MSG_KEXINIT
      msg.cookie.should == Array.new(16, 0)
      msg.kex_algorithms.should be_empty
      msg.server_host_key_algorithms.should be_empty
      msg.encryption_algorithms_client_to_server.should be_empty
      msg.encryption_algorithms_server_to_client.should be_empty
      msg.mac_algorithms_client_to_server.should be_empty
      msg.mac_algorithms_server_to_client.should be_empty
      msg.compression_algorithms_client_to_server.should be_empty
      msg.compression_algorithms_server_to_client.should be_empty
      msg.languages_client_to_server.should be_empty
      msg.languages_server_to_client.should be_empty
      msg.first_kex_packet_follows.should be_false
      msg.reserved.should == 0
    end

    it "an object with some data assigned" do
      payload = [
        Nexop::Message::KexInit::SSH_MSG_KEXINIT, # type
        5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, # cookie
        0, 0, 0, 3, 97, 44, 98, # kex_algorithms
        0, 0, 0, 3, 99, 44, 100, # server_host_key_algorithms
        0, 0, 0, 3, 101, 44, 102, # encryption_algorithms_client_to_server
        0, 0, 0, 3, 103, 44, 104, # encryption_algorithms_server_to_client
        0, 0, 0, 3, 105, 44, 106, # mac_algorithms_client_to_server
        0, 0, 0, 3, 107, 44, 108, # mac_algorithms_server_to_client
        0, 0, 0, 3, 109, 44, 110, # compression_algorithms_client_to_server
        0, 0, 0, 3, 111, 44, 112, # compression_algorithms_server_to_client
        0, 0, 0, 3, 113, 44, 114, # languages_client_to_server
        0, 0, 0, 3, 115, 44, 116, # languages_server_to_client
        0, # first_kex_packet_follows
        0, 0, 0, 0 # 0 (reserved for future extension)
      ].pack("C*")
      msg = Nexop::Message::KexInit.parse(payload)

      msg.type.should == Nexop::Message::KexInit::SSH_MSG_KEXINIT
      msg.cookie.should == Array.new(16, 5)
      msg.kex_algorithms.should == [ "a", "b" ]
      msg.server_host_key_algorithms.should == [ "c", "d" ]
      msg.encryption_algorithms_client_to_server.should == [ "e", "f" ]
      msg.encryption_algorithms_server_to_client.should == [ "g", "h" ]
      msg.mac_algorithms_client_to_server.should == [ "i", "j" ]
      msg.mac_algorithms_server_to_client.should == [ "k", "l" ]
      msg.compression_algorithms_client_to_server.should == [ "m", "n" ]
      msg.compression_algorithms_server_to_client.should == [ "o", "p" ]
      msg.languages_client_to_server.should == [ "q", "r" ]
      msg.languages_server_to_client.should == [ "s", "t" ]
      msg.first_kex_packet_follows.should be_false
      msg.reserved.should == 0
    end
  end
end
