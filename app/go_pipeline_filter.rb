require 'go_pipeline'

class GoPipelineFilter
  def initialize inclusions
    @inclusions = inclusions
  end
  
  def apply stages
    pipelines = @inclusions.map{|inclusion| GoPipeline.new inclusion }
    stages.each do |stage|
      pipeline = pipelines.find {|p| p.name == stage.pipeline_name }
      pipeline.stages << stage if pipeline
    end
    return pipelines
  end
end