require 'go_pipeline'

class GoPipelineFilter
  def initialize inclusions, exclusions
    @inclusions = inclusions
    @exclusions = exclusions
  end
  
  def apply stages
    pipelines = filter stages
    populate pipelines, stages
    return pipelines
  end
  
  private
  
  def filter stages
    filtered_names = stages.map(&:pipeline_name).uniq
    
    filtered_names.reject! { |name| @exclusions.include?(name) }
    filtered_names.select! { |name| @inclusions.include?(name) } unless @inclusions.size == 0
   filtered_names.map{|name| GoPipeline.new name }
  end
  
  def populate pipelines, stages
    stages.each do |stage|
      pipeline = pipelines.find {|p| p.name == stage.pipeline_name }
      pipeline.stages << stage if pipeline
    end
  end
end