require 'spec_helper'

describe Nexop::Handler::Base do
  let(:arg) { "arg" }
  let(:obj) { double(:a_method => nil) }
  let(:handler) { Nexop::Handler::Base.new(obj.method(:a_method)) }

  context "send_message" do
    it "acts as a proxy" do
      obj.should_receive(:a_method).with(arg)
      handler.send_message(arg)
    end
  end

  context "finished" do
    it "is false by default" do
      handler.should_not be_finished
    end

    it "can be changed" do
      handler.send(:make_finish)
      handler.should be_finished
    end
  end

  context "tick" do
    it "must be implemented" do
      expect{ handler.tick(nil) }.to raise_error(NotImplementedError)
    end
  end

  context "finalize" do
    it "makes nothing" do
      handler.finalize
    end
  end
end
