require 'spec_helper'

describe Nexop::Handler::Base do
  let(:arg) { "arg" }
  let(:obj) { double }
  let(:handler) { Nexop::Handler::Base.new(obj.method(:a_method)) }

  context "send_message" do
    it "acts as a proxy" do
      obj.should_receive(:a_method).with(arg)
      handler.send_message(arg)
    end
  end
end
