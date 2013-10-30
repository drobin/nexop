require 'spec_helper'

describe Nexop::Keystore::NoneCipher do
  let(:cipher) { Nexop::Keystore::NoneCipher.new }

  context "update" do
    it "returns data if buffer is nil" do
      data = "123"
      cipher.update(data, nil).should equal(data)
    end

    it "appends data to buffer if buffer is not-nil" do
      data = "123"
      buffer = "xxx"
      cipher.update(data, buffer).should equal(buffer)
      buffer.should == "xxx123"
    end
  end
end
