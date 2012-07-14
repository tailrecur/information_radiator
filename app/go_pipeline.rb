require 'json'

require 'nokogiri'

class GoPipeline 
  def initialize name, http_handler
    @name = name
    @http_handler = http_handler
    @stages = []
  end
  attr_reader :stages, :name
  
  def status
    stages.any?{|s| s.failed? } ? "failed" : "passed"
  end
  
  def activity 
    stages.any?{|s| s.building? } ? "building" : "sleeping"
  end
  
  def failed_stage 
    stages.find(&:failed?)
  end
  
  def build_breakers
    stages = Nokogiri::XML(@http_handler.retrieve("/api/pipelines/#{name}/stages.xml"))
    failed_entry = stages.css("entry").find {|entry| entry.at("id").content.include?(failed_stage.name) }
    failed_entry.css("author").map {|author| author.at("name").content.match(/(.+) <.*>/)[1] }
  end
  
  def to_json options={}
    pipeline = {name: name, status: status, activity: activity}
    pipeline[:buildBreakers] = build_breakers if failed_stage
    pipeline.to_json
  end
  
  def == other
    other.is_a?(GoPipeline) and self.name == other.name
  end
end

class GoStage
  def initialize opts
    @opts = opts
    @id, @name, @pipeline_name = opts[:id], opts[:name], opts[:pipeline_name]
  end
  
  def failed?
    @opts[:status] == "Failure"
  end
  
  def building?
    @opts[:activity] == "Building"
  end
  
  attr_reader :pipeline_name, :name, :id
end
