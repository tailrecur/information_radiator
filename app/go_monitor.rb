require 'nokogiri'
require 'http_handler'
require 'go_pipeline'

class GoMonitor
  def initialize hashie
    @http_handler = HttpHandler.new(go_base_url(hashie.url))
    @http_handler.auth(hashie.username, hashie.password) if hashie.username && hashie.password
    @pipelines = hashie.pipelines.inclusions.map{|name| Pipeline.new name }
    @refresh_rate = hashie.refresh_rate || 15
  end
  attr_reader :pipelines, :refresh_rate

  def refresh_data
    pipelines.each(&:clear!)
    parse_data(Nokogiri::XML(@http_handler.retrieve("/cctray.xml")))
    return pipelines
  end
  
  def type
    "go"
  end
  
  private
  
  def parse_data projects
    stages = projects.css("Project").find_all {|p| p["name"].split("::").size == 2 }.map {|p| Stage.new(p["name"], p["lastBuildStatus"], p["activity"])}
    stages.each do |stage|
      pipeline = pipelines.find {|p| p.name == stage.pipeline_name }
      pipeline.stages << stage if pipeline
    end
  end
    
  def go_base_url url
    (url.match(/\/$/) ? url.chop : url) + "/go"
  end
end



