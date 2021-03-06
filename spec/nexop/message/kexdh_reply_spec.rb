require 'spec_helper'

describe Nexop::Message::KexdhReply do
  let(:msg) { Nexop::Message::KexdhReply.new }
  let(:hostkey) { double(:priv => Object.new, :pub => Object.new, :to_ssh => "xxx") }

  it "has a type-field" do
    msg.type.should == Nexop::Message::KexdhReply::SSH_MSG_KEXDH_REPLY
  end

  it "has a k_s field" do
    msg.hostkey = double(:to_ssh => "xxx")
    msg.k_s.unpack("A*").should == ["xxx"]
  end

  context "kex_algorithm" do
    it "readable" do
      msg.kex_algorithm.should be_nil
    end

    it "is writable with diffie-hellman-group1-sha1" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.kex_algorithm.should == "diffie-hellman-group1-sha1"
    end

    it "is writeable with diffie-hellman-group14-sha1" do
      msg.kex_algorithm = "diffie-hellman-group14-sha1"
      msg.kex_algorithm.should == "diffie-hellman-group14-sha1"
    end

    it "cannot be updates with an invalid algorithm" do
      expect{ msg.kex_algorithm = "xxx" }.to raise_error(ArgumentError)
    end
  end

  context "p" do
    it "is nil by default" do
      msg.p.should be_nil
    end

    it "is updated, when the kex_algorithm is set to diffie-hellman-group1-sha1" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.p.should == Nexop::Prime.to_i(Nexop::Prime::MODP_GROUP1)
    end

    it "is updated, when the kex_algorithm is set to diffie-hellman-group14-sha1" do
      msg.kex_algorithm = "diffie-hellman-group14-sha1"
      msg.p.should == Nexop::Prime.to_i(Nexop::Prime::MODP_GROUP14)
    end
  end

  context "g" do
    it "is nil by default" do
      msg.g.should be_nil
    end

    it "is updated, when the kex_algorithm is set to diffie-hellman-group1-sha1" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.g.should == 2
    end

    it "is updated, when the kex_algorithm is set to diffie-hellman-group14-sha1" do
      msg.kex_algorithm = "diffie-hellman-group14-sha1"
      msg.g.should == 2
    end
  end

  context "dh" do
    it "creates an OpenSSL::PKey::DH instance" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.dh.should be_a(OpenSSL::PKey::DH)
    end

    it "aborts when you don't have a p and g" do
      expect{ msg.dh }.to raise_error(ArgumentError)
    end
  end

  context "f" do
    it "is readable" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.f.should be_a(Bignum)
    end

    it "aborts when you don't have p and g" do
      expect{ msg.f }.to raise_error(ArgumentError)
    end
  end

  context "e" do
    it "is readable" do
      msg.e.should be_nil
    end

    it "is updatable" do
      msg.e = 2
      msg.e.should == 2
    end
  end

  context "K" do
    it "computes the shared secret" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.e = 4711
      msg.K.should be_a(Bignum)
    end

    it "aborts when you don't have dh and e" do
      expect{ msg.K }.to raise_error(ArgumentError)
    end
  end

  context "shared_secret" do
    it "is an alias for K" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.e = 4711
      msg.shared_secret.should be_a(Bignum)
    end
  end

  context "calc_H" do
    let(:hostkey) { double(:to_ssh => "xxx") }

    it "calculates the exchange hash" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.e = 4711
      msg.hostkey = hostkey
      h = msg.calc_H("v_c", "v_s", "i_c", "i_s")
      h.should have(20).elements
      msg.H.should equal(h)
    end

    it "aborts when you don't have dh, e and hostkey" do
      expect{ msg.calc_H }.to raise_error(ArgumentError)
    end
  end

  context "H" do
    it "is nil by default" do
      msg.H.should be_nil
    end
  end

  context "exchange_hash" do
    it "is an alias for H" do
      msg.kex_algorithm = "diffie-hellman-group1-sha1"
      msg.e = 4711
      msg.hostkey = hostkey
      h = msg.calc_H("v_c", "v_s", "i_c", "i_s")
      msg.exchange_hash.should equal(h)
    end
  end

  context "sig_h" do
    it "calculates the hash over H" do
      msg.hostkey = hostkey
      msg.stub(:H).and_return("abc")
      msg.hostkey.priv.should_receive(:sign).and_return("xxx")
      msg.sig_h.unpack("C4A7C4C*").should == [0, 0, 0, 7, 'ssh-rsa', 0, 0, 0, 3, 120, 120, 120]
    end

    it "aborts if H is not calculated" do
      msg.hostkey = hostkey
      msg.stub(:H).and_return(nil)
      expect{ msg.sig_h }.to raise_error(ArgumentError)
    end
  end
end
