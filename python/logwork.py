import base
from dateutil import parser.isoparse

def format_time(time_str):
    dt = isoparse(time_str)
    return 
  Time.parse(time_str).iso8601(3).sub(/(.*):/, '\1')


def send_request(uri, req)
  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true
  # http.set_debug_output $stdout
  res = http.request(req)
  JSON.parse res.body
end

def log_work(issue, started, time_spent, production)
  puts " > Logging #{time_spent} of work on Issue #{issue} on #{started}"
  return unless production

  uri = URI("#{JIRA_BASE_URI}/rest/api/3/issue/#{issue}/worklog?notifyUsers=false")
  req = Net::HTTP::Post.new(uri, 'content-type': 'application/json')

  req.basic_auth CONFIG[:atlassian_username], CONFIG[:atlassian_api_token]

  req.body = {
    started: format_time(started),
    timeSpent: time_spent
  }.to_json

  send_request uri, req
end

return unless $PROGRAM_NAME == __FILE__

# ./log-work.rb LIO-12127 '2019-09-01 10:00' 1h
issue = ARGV[0]
time_str = ARGV[1]
worked = ARGV[2]
production = ARGV[3].to_s.downcase == true

puts log_work issue, time_str, worked, production
