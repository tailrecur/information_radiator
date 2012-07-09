$LOAD_PATH << File.expand_path("../../app", __FILE__)

require 'hashie'
require 'httparty'
require 'rspec/expectations'

RSpec.configure do |config|
  # config.mock_with :mocha
end
