require 'spec_helper'
require 'go_pipeline_filter'
require 'go_pipeline'

describe GoPipelineFilter do
  
  def stage name
    GoStage.new(name, "any", "any")
  end

  
  context "when only inclusions are specified" do
    it "should return only inclusions" do
      filter = GoPipelineFilter.new(["foo", "bar"])
      pipelines = filter.apply([stage("foo :: stage"), stage("foo :: stage2"), stage("bar :: bar_stage"), stage("any :: stage")])
      pipelines.size.should == 2
      pipelines.first.name.should == "foo"
      pipelines.first.stages.size.should == 2
      pipelines.first.stages.first.name.should == "stage"
      pipelines.first.stages.last.name.should == "stage2"
      pipelines.last.name.should == "bar"
      pipelines.last.stages.size.should == 1
      pipelines.last.stages.first.name.should == "bar_stage"
    end
  end
end
  
  