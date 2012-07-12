require 'json'

class GoPipeline 
  def initialize name
    @name = name
    @stages = []
  end
  attr_reader :stages, :name
  
  def clear!
    @stages = []
  end
  
  def status
    stages.all?{|s| s.status == "Success"} ? "passed" : "failed"
  end
  
  def activity 
    stages.all?{|s| s.activity == "Sleeping"} ? "sleeping" : "building"
  end
  
  def to_json options={}
    {name: name, status: status, activity: activity}.to_json
  end
  
  def == other
    other.is_a?(GoPipeline) and self.name == other.name
  end
end

class GoStage
  def initialize name, status, activity
    @pipeline_name, @name = name.split(" :: ")
    @status = status
    @activity = activity
  end
  attr_reader :pipeline_name, :name, :status, :activity
end
