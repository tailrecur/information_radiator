require 'go/pipeline'

class GoPipelineFilter
  def initialize http_handler, inclusions, exclusions
    @http_handler = http_handler
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
    filtered_names.reject! { |name| @exclusions.any? { |exclusion| exclusion.match(/\/(.*)\//) ? name.match(Regexp.new($1)) : exclusion == name }}
    if @inclusions.size > 0
      filtered_names.select! { |name| @inclusions.any? { |inclusion| inclusion.match(/\/(.*)\//) ? name.match(Regexp.new($1)) : inclusion == name }}
    end
    filtered_names.map{|name| GoPipeline.new name, @http_handler }
  end
  
  def populate pipelines, stages
    stages.each do |stage|
      pipeline = pipelines.find {|p| p.name == stage.pipeline_name }
      pipeline.stages << stage if pipeline
    end
  end
end