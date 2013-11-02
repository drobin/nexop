require 'spec_helper'

describe Nexop::Handler::Kex do
  let(:keystore) { Nexop::Keystore.new }
  let(:receiver) { double(:m => nil)}
  let(:kex) { Nexop::Handler::Kex.new(keystore, receiver.method(:m)) }
  let(:hostkey) { Nexop::Hostkey.generate(1014) }

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

  context "guess_kex_algorithm" do
    before(:each) { kex.receive_kex_init(Nexop::Message::KexInit.new) }

    it "selects the preferred algorithm if both party have the same preferred algorithm" do
      kex.kex_init(:c2s).kex_algorithms = [ "abc", "xxx" ]
      kex.kex_init(:s2c).kex_algorithms = [ "abc", "yyy" ]
      kex.guess_kex_algorithm.should == "abc"
    end

    it "selects the first client algorithm which the server also supports" do
      kex.kex_init(:c2s).kex_algorithms = [ "abc", "xxx", "foo" ]
      kex.kex_init(:s2c).kex_algorithms = [ "yyy", "bar", "xxx" ]
      kex.guess_kex_algorithm.should == "xxx"
    end
  end

  context "guess_encryption_algorithm" do
    before(:each) { kex.receive_kex_init(Nexop::Message::KexInit.new) }

    it "c2s selects the first client algorithm, the server also supports" do
      kex.kex_init(:c2s).encryption_algorithms_client_to_server = [ "abc", "xxx", "foo" ]
      kex.kex_init(:s2c).encryption_algorithms_client_to_server = [ "yyy", "bar", "xxx" ]
      kex.guess_encryption_algorithm(:c2s).should == "xxx"
    end

    it "s2c selects the first client algorithm, the server also supports" do
      kex.kex_init(:c2s).encryption_algorithms_server_to_client = [ "abc", "xxx", "foo" ]
      kex.kex_init(:s2c).encryption_algorithms_server_to_client = [ "yyy", "bar", "xxx" ]
      kex.guess_encryption_algorithm(:s2c).should == "xxx"
    end
  end

  context "guess_mac_algorithm" do
    before(:each) { kex.receive_kex_init(Nexop::Message::KexInit.new) }

    it "c2s selects the first client algorithm, the server also supports" do
      kex.kex_init(:c2s).mac_algorithms_client_to_server = [ "abc", "xxx", "foo" ]
      kex.kex_init(:s2c).mac_algorithms_client_to_server = [ "yyy", "bar", "xxx" ]
      kex.guess_mac_algorithm(:c2s).should == "xxx"
    end

    it "s2c selects the first client algorithm, the server also supports" do
      kex.kex_init(:c2s).mac_algorithms_server_to_client = [ "abc", "xxx", "foo" ]
      kex.kex_init(:s2c).mac_algorithms_server_to_client = [ "yyy", "bar", "xxx" ]
      kex.guess_mac_algorithm(:s2c).should == "xxx"
    end
  end

  context "prepare" do
    before(:each) { kex.prepare(hostkey, "V_C", "V_S") }

    it "assigns the hostkey to an instance-variable" do
      kex.instance_variable_get(:@hostkey).should equal(hostkey)
    end

    it "assigns the client identification to an instance-variable" do
      kex.instance_variable_get(:@v_c).should == "V_C"
    end

    it "assigns the server identification to an instance-variable" do
      kex.instance_variable_get(:@v_s).should == "V_S"
    end
  end

  context "tick" do
    context "step 1" do
      it "fails if you don't receive a SSH_MSG_KEXINIT" do
        expect{ kex.tick("xxx") }.to raise_error(ArgumentError)
        kex.kex_init(:c2s).should be_nil
      end

      it "receives and sends back a SSH_MSG_KEXINIT" do
        c2s = Nexop::Message::KexInit.new
        receiver.should_receive(:m).with(kex.kex_init(:s2c))
        kex.tick(c2s.serialize).should be_true
        kex.kex_init(:c2s).should == c2s
      end
    end

    context "step 2" do
      before(:each) { kex.instance_variable_set(:@kex_step, 2) }
      before(:each) { kex.prepare(hostkey, "V_C", "V_S") }
      before(:each) { kex.receive_kex_init(Nexop::Message::KexInit.new) }

      it "fails of you don't receive a SSH_MSG_KEXDH_INIT" do
        expect{ kex.tick("xxx") }.to raise_error(ArgumentError)
      end

      it "receives SSH_MSG_KEXDH_INIT and send back SSH_MSG_KEXDH_REPLY" do
        request = Nexop::Message::KexdhInit.new
        request.e = 4711
        receiver.should_receive(:m) do |msg|
          msg.should be_a_kind_of(Nexop::Message::KexdhReply)
        end

        kex.tick(request.serialize).should be_true
      end
    end

    context "step 3" do
      let(:dh_reply) { Nexop::Message::KexdhReply.new }

      before(:each) { kex.receive_kex_init(Nexop::Message::KexInit.new) }

      before(:each) do
        dh_reply.kex_algorithm = "diffie-hellman-group1-sha1"
        dh_reply.e = 4711
        dh_reply.hostkey = hostkey
        dh_reply.calc_H("v_c", "v_s", "i_c", "i_s")
      end

      before(:each) { kex.instance_variable_set(:@kex_step, 3) }
      before(:each) { kex.instance_variable_set(:@dh_reply, dh_reply) }

      [ :c2s, :s2c ].each do |direction|
        before(:each) { kex.kex_init(direction).encryption_algorithms_client_to_server = [ "none"] }
        before(:each) { kex.kex_init(direction).encryption_algorithms_server_to_client = [ "none"] }
        before(:each) { kex.kex_init(direction).mac_algorithms_client_to_server = [ "none"] }
        before(:each) { kex.kex_init(direction).mac_algorithms_server_to_client = [ "none"] }
      end

      it "fails if you don't receive a SSH_MSG_NEWKEYS" do
        expect{ kex.tick("xxx") }.to raise_error(ArgumentError)
      end

      it "receives and sends back SSH_MSG_NEWKEYS" do
        request = Nexop::Message::NewKeys.new
        receiver.should_receive(:m).with(request)
        kex.tick(request.serialize).should be_false
      end

      it "assigns the keys to the keystore" do
        keystore.should_receive(:keys!)
        kex.tick(Nexop::Message::NewKeys.new.serialize)
      end

      it "assigns the algorithms to the keystore" do
        keystore.should_receive(:algorithms!).with(:c2s, "none", "none")
        keystore.should_receive(:algorithms!).with(:s2c, "none", "none")
        kex.tick(Nexop::Message::NewKeys.new.serialize)
      end
    end
  end
end
