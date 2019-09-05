#!/usr/bin/env ruby

require_relative 'base'

def format_time(time_str)
  Time.parse(time_str).iso8601(3).sub(/(.*):/, '\1')
end

def log_work(issue, started, timeSpent)

  puts " > Logging #{timeSpent} of work on Issue #{issue} on #{started}"
  return unless CONFIG[:production] == true

  uri = URI("#{JIRA_BASE_URI}/rest/api/3/issue/#{issue}/worklog?notifyUsers=false")
  req = Net::HTTP::Post.new(uri, 'content-type': 'application/json')

  req.basic_auth CONFIG[:atlassian_username], CONFIG[:atlassian_api_token]

  req.body = {
    started: format_time(started),
    timeSpent: timeSpent
  }.to_json

  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true
  # http.set_debug_output $stdout
  res = http.request(req)
  JSON.parse res.body
end

return unless __FILE__ == $0

# ./log-work.rb LIO-12127 '2019-09-01 10:00' 1h
issue = ARGV[0]
time_str = ARGV[1]
worked = ARGV[2]

puts log_work issue, time_str, worked
