$LOAD_PATH << File.expand_path("..", __FILE__)

require 'sinatra'
require 'hashie'
require 'radiator'
require 'yaml'
require 'json'
require 'haml'

radiator = Radiator.new(Hashie::Mash.new(YAML.load_file("config.yml")))

get '/' do
  haml :index
end

get "/monitors" do
  radiator.monitors.map {|m| {id: radiator.monitors.index(m), type: m.type, refresh_rate: m.refresh_rate } }.to_json
end

get "/monitors/:id" do |id|
  begin
    radiator.monitors[id.to_i].refresh_data.to_json
  rescue Exception => e
    [ 500, {message: e.message}.to_json ]
  end
end
