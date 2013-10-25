require 'spec_helper'

describe Nexop::Session do
  let(:session) { Nexop::Session.new }

  it "has an empty input-buffer after creation" do
    session.ibuf.should == ""
  end

  it "has an empty output-buffer after creation" do
    session.obuf.should == ""
  end
end
