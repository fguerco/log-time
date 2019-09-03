require_relative 'base.rb'

def log_work(issue, started, timeSpent)

  uri = URI("#{JIRA_BASE_URI}/rest/api/2/issue/#{issue}/worklog")
  req = Net::HTTP::Post.new(uri, 'content-type': 'application/json')
  #uri = URI("#{JIRA_BASE_URI}/rest/api/2/issue/#{issue}?fields=summary")
  #req = Net::HTTP::Get.new(uri)

  req.basic_auth LOGIN_INFO[:username], LOGIN_INFO[:api_key]

  req.body = {
    started: started,
    timeSpent: timeSpent
  }.to_json

  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true
  http.set_debug_output $stdout
  res = http.request(req)
  JSON.parse res.body
end

p log_work "LIO-11750", Date.today.iso8601, "1h"
