require 'spec_helper'
require 'go_pipeline_filter'
require 'go_pipeline'

describe GoPipelineFilter do
  
  def stage pipeline_name, name
    GoStage.new({pipeline_name: pipeline_name, name: name})
  end

  context "when only inclusions are specified" do
    it "should return only inclusions" do
      filter = GoPipelineFilter.new(nil, ["foo", "bar"],[])
      pipelines = filter.apply([stage("foo", "stage"), stage("foo", "stage2"), stage("bar", "bar_stage"), stage("any", "stage")])
      pipelines.map(&:name).should == ["foo", "bar"]
      pipelines.first.stages.map(&:name).should == ["stage", "stage2"]
      pipelines.last.stages.map(&:name).should == ["bar_stage"]
    end
  end

  context "when only exclusions are specified" do
    it "should return everything except exclusions" do
      filter = GoPipelineFilter.new(nil, [], ["foo", "baz"])
      pipelines = filter.apply([stage("foo", "stage"), stage("foo", "stage2"), stage("bar", "bar_stage"), stage("baz", "bar_stage"), stage("any", "stage")])
      pipelines.map(&:name).should == ["bar", "any"]
      pipelines.first.stages.map(&:name).should == ["bar_stage"]
      pipelines.last.stages.map(&:name).should == ["stage"]
    end
  end
end
  
  