require 'yaml'
require 'json'
require 'net/http'
require 'uri'

def file_path
  ENV['HOME'] + '/.atlassian/bitbucket.yml'
end

d45RPPbCyXW7Ip6fggHz14A1

def http_request(key, secret, username, password)
  uri = URI("https://bitbucket.org/site/oauth2/access_token")
  req = Net::HTTP::Post.new(uri)
  req.basic_auth key, secret
  req.set_form_data grant_type: 'password', username: username, password: password

  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true
  #http.set_debug_output $stdout
  res = http.request(req)
  JSON.parse res.body
end

data = YAML.load_file(file_path)

login_response = http_request(data['key'], data['secret'], data['username'], data['password'])
p login_response
access_token = login_response['access_token']
p access_token
