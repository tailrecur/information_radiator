require 'spec_helper'
require 'go_pipeline'
require 'go_pipeline_orderer'

describe "GoPipelineOrderer" do
  def pipelines(*names)
    names.map {|name| GoPipeline.new(name, nil) }
  end
  
  context "when no ordering is specified" do
    it "should return the original array" do
      orderer = GoPipelineOrderer.new(nil)
      ordered = orderer.apply(pipelines("test1", "test2", "test4"))
      ordered.map(&:name).should == ["test1", "test2", "test4"]
    end
  end
  
  context "when exact match is specified" do
    it "should put mentioned pipelines first" do
      orderer = GoPipelineOrderer.new(["test4", "test2"])
      ordered = orderer.apply(pipelines("test1", "test2", "test4"))
      ordered.map(&:name).should == ["test4", "test2", "test1"]
    end
    
    it "should sort alphabetically when pipeline is not specified" do
      orderer = GoPipelineOrderer.new(["test4", "test2"])
      ordered = orderer.apply(pipelines("test1", "test2", "test3", "test4"))
      ordered.map(&:name).should == ["test4", "test2", "test1", "test3"]
    end
  end
  
  context "when regex is specified" do
    it "should put mentioned pipelines first" do
      orderer = GoPipelineOrderer.new(["/.*high.*/", "/.*medium.*/"])
      ordered = orderer.apply(pipelines("test1", "medium1", "23high", "test4", "xmedium2", "thigh-bone", "foo"))
      ordered.map(&:name).should == ["23high", "thigh-bone", "medium1", "xmedium2", "foo", "test1", "test4"]
    end
  end
end