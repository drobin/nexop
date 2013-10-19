require 'spec_helper'
require 'tempfile'

describe Nexop::Hostkey do
  def dump_pem(key)
    Tempfile.open(File.basename(__FILE__, ".rb")) do |f|
      f.write(key.to_pem)
      f.path
    end
  end

  let(:hostkey) { Nexop::Hostkey.from_file(@priv_path, @pub_path) }

  before(:each) do
    rsa = OpenSSL::PKey::RSA.generate(1024)
    @priv_path = dump_pem(rsa)
    @pub_path = dump_pem(rsa.public_key)
  end

  after(:each) do
    File.unlink(@priv_path)
    File.unlink(@pub_path)
  end

  context "from_file" do
    it "automatically evaluates the path of the public key" do
      hk = Nexop::Hostkey.from_file("xxx")
      hk.priv_path.should == "xxx"
      hk.pub_path.should == "xxx.pub"
    end

    it "can specify a separate path for the public key" do
      hk = Nexop::Hostkey.from_file(@priv_path, @pub_path)
      hk.priv_path.should == @priv_path
      hk.pub_path.should == @pub_path
    end
  end

  context "pub" do
    it "returns the public key" do
      key = hostkey.pub
      key.should be_a_kind_of(OpenSSL::PKey::RSA)
      key.should be_public
    end

    it "caches the key" do
      key = hostkey.pub
      hostkey.pub.should equal(key)
    end

    it "raises an error, if the file does not exist" do
      expect{ Nexop::Hostkey.from_file("xxx").pub }.to raise_error(Errno::ENOENT)
    end
  end

  context "priv" do
    it "returns the private key" do
      key = hostkey.priv
      key.should be_a_kind_of(OpenSSL::PKey::RSA)
      key.should be_private
    end

    it "caches the key" do
      key = hostkey.priv
      hostkey.priv.should equal(key)
    end

    it "raises an error, if the file does not exist" do
      expect{ Nexop::Hostkey.from_file("xxx").priv }.to raise_error(Errno::ENOENT)
    end
  end
end
