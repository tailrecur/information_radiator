require 'json'
require 'nokogiri'
require 'forwardable'

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
  
  def label
    stages.first.label
  end
  
  def to_json options={}
    pipeline = {name: name, status: status, activity: activity, label: label}
    if failed_stage
      puts name
      puts stages
      pipeline[:triggerer] = stages.map(&:triggerer).uniq.compact.first
      pipeline[:buildBreakers] = failed_stage.authors
    end
    pipeline.to_json
  end
  
  def == other
    other.is_a?(GoPipeline) and self.name == other.name
  end
  
  def refresh_data
    begin
      stage_entries = Nokogiri::XML(@http_handler.retrieve("/api/pipelines/#{name}/stages.xml")).css("entry").map{|entry| GoStageEntry.new(entry) }
      stages.each do |stage| 
        stage.entry = stage_entries.find{|entry| entry.id == stage.id } 
        stage.entry = GoStageEntry.new(nil) unless stage.entry
      end
    rescue Exception => e
      puts "Pipeline: #{name}"
      puts e.message
      puts e.backtrace.join("\n")
      stages.each{ |stage| stage.entry = GoStageEntry.new(nil) }
    end
  end
end

class GoStageEntry 
  def initialize entry
    @id = entry.at("id").content.match(/\/go\/pipelines\/(.+)/)[1] rescue nil
    @authors = entry.css("author").map {|author| author.at("name").content.match(/(.+) <.*>/)[1] } rescue []
    @triggerer = entry.to_s.match(/<go:name><!\[CDATA\[(.*)\]\]><\/go:name>/)[1] rescue nil
  end
  
  attr_reader :id, :authors, :triggerer
end

class GoStage
  def initialize opts
    @opts = opts
    @id, @name, @pipeline_name, @label = opts[:id], opts[:name], opts[:pipeline_name], opts[:label]
  end
  
  def failed?
    @opts[:status] == "Failure"
  end
  
  def building?
    @opts[:activity] == "Building"
  end
  
  def entry= entry
    @entry = entry
  end
  
  def to_s
    @entry.inspect
  end
  
  extend Forwardable
  def_delegators :@entry, :triggerer, :authors
  
  attr_reader :pipeline_name, :name, :id, :label, :entry
end
