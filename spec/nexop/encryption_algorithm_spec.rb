require 'spec_helper'

describe Nexop::EncryptionAlgorithm do
  it "DES is a valid algorithm" do
    Nexop::EncryptionAlgorithm.supported?(Nexop::EncryptionAlgorithm::DES).should be_true
  end

  it "NONE is a valid algorithm" do
    Nexop::EncryptionAlgorithm.supported?(Nexop::EncryptionAlgorithm::NONE).should be_true
  end

  it "xxx is an invalid algorithm" do
    Nexop::EncryptionAlgorithm.supported?("xxx").should be_false
  end
end
