require 'go/monitor'

class MonitorFactory
  def self.create hashie
    GoMonitor.new(hashie.go) if hashie.keys.include?("go")
  end
end