require 'monitor_factory'

class Radiator
  def initialize hashie
    @monitors = hashie.monitors.map { |hash| MonitorFactory.create hash }
  end
  
  attr_reader :monitors
end
