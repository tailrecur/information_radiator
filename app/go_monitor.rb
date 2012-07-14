require 'nokogiri'
require 'http_handler'
require 'go_pipeline_filter'

class GoMonitor
  def initialize hashie
    @http_handler = HttpHandler.new(go_base_url(hashie.url))
    @http_handler.auth(hashie.username, hashie.password) if hashie.username && hashie.password
    @pipeline_filter = GoPipelineFilter.new(hashie.pipelines.inclusions || [], hashie.pipelines.exclusions || [])
    @refresh_rate = hashie.refresh_rate || 15
  end
  attr_reader :refresh_rate

  def refresh_data
    begin
      parse_data(Nokogiri::XML(@http_handler.retrieve("/cctray.xml")))
    rescue Exception => e
      puts e.message
      puts e.backtrace.join("\n")
      raise "Cannot connect to GO server"
    end
  end
  
  def type
    "go"
  end
  
  private
  
  def parse_data projects
    stages = projects.css("Project").find_all {|p| p["name"].split("::").size == 2 }.map {|p| GoStage.new(p["name"], p["lastBuildStatus"], p["activity"])}
    @pipeline_filter.apply(stages)
  end
    
  def go_base_url url
    (url.match(/\/$/) ? url.chop : url) + "/go"
  end
end



