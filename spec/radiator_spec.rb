require 'spec_helper'
require 'radiator'

describe Radiator do
  it "should do nothing if no monitors are defined" do
    Radiator.new Hashie::Mash.new(monitors: {})
  end

  it "should call monitor factory for each monitor" do
    MonitorFactory.should_receive(:create).twice.with(kind_of(Hashie::Mash)).and_return("a monitor")
    config = Radiator.new Hashie::Mash.new(monitors: [{foo: {}}, {foo: {}}])
    config.monitors.size.should == 2
  end
end