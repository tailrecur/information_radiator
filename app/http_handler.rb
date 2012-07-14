require 'httparty'

class HttpHandler
  def initialize base_url
    @base_url = base_url
  end
  
  def auth username, password
    @auth = {username: username, password: password }
    self
  end
  
  def retrieve uri
    HTTParty.get(@base_url + uri, basic_auth: @auth, timeout: 2)
  end
end