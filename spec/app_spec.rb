require 'spec_helper'
require 'sinatra'
require 'rack/test'
require 'app'

set :environment, :test
set :raise_errors, true

def app
  Sinatra::Application
end

describe "App" do
  include Rack::Test::Methods
  
  xit "should be ok" do
    get "/"
    response.should be_ok
  end
  
  xit "should return all monitors json" do
    get "/monitors"
    puts last_response.body
  end

  xit "should return json for a monitor" do
    get "/monitors/0"
    puts last_response.body
  end
end