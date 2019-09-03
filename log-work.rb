#!/usr/bin/env ruby

require_relative 'base'

def format_time(year, month, day, hour, minute = 0)
  Time.new(year, month, day, hour, minute).iso8601(3).sub(/(.*):/, '\1')
end

def log_work(issue, started, timeSpent)

  uri = URI("#{JIRA_BASE_URI}/rest/api/3/issue/#{issue}/worklog?notifyUsers=false")
  req = Net::HTTP::Post.new(uri, 'content-type': 'application/json')

  req.basic_auth LOGIN_INFO[:username], LOGIN_INFO[:api_key]

  req.body = {
    started: started,
    timeSpent: timeSpent
  }.to_json

  http = Net::HTTP.new(uri.hostname, uri.port)
  http.use_ssl = true
  # http.set_debug_output $stdout
  res = http.request(req)
  JSON.parse res.body
end

date = format_time(2019, 9, 3, 8)
p log_work "LIO-12127", date, "1h"
# "2019-09-03T08:37:20.972-0300"
