require 'spec_helper'
require 'monitor_factory'

describe MonitorFactory do
  it "should create go monitor" do
    GoMonitor.should_receive(:new).with(Hashie::Mash.new(foo: :bar)).and_return("baz")
    MonitorFactory.create(Hashie::Mash.new(go: {foo: :bar})).should == "baz"
  end
end