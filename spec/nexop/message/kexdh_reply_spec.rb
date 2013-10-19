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
end
