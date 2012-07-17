class GoPipelineOrderer
  MAX_INTEGER = 100000
  
  def initialize ordering
    @ordering = ordering || []
  end
  
  def apply pipelines
    pipelines.sort do |left,right|
      left_index = index pipelines, left.name
      right_index = index pipelines, right.name
      left_index != right_index ? left_index <=> right_index : left.name <=> right.name
    end
  end
  
  private 
  
  def index pipelines, name 
    index = @ordering.index do |ordering| 
      ordering.match(/\/(.*)\//) ? name.match(Regexp.new($1)) : ordering == name
    end 
    index || MAX_INTEGER
  end
end