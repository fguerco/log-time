#!/usr/bin/env ruby

require 'date'

projects_folder = ENV['HOME'] + '/dev/lio/projects'

def date_formatted(date)
  date.strftime('%Y-%m-%d')
end

def parse_commit_line(line)
  m = line.match(/(\d{4}-\d{2}-\d{2})(?:.*)(LIO-\d+)/)
  return nil if m.nil?
  { date: m[1], issue: m[2] }
end

today = date_formatted(Date.today)
last_month = date_formatted(Date.today - 30)

issues = []


projects = %x[find #{projects_folder} -name '.git' -type d].split.map { |d| File.dirname(d) }
projects.each do |path|
  # puts path
  Dir.chdir path
  name = %x[git config user.name]
  lines = %x[git log --date=iso --format="%ad %s" --all --after="#{last_month}" --until="#{today}" --author="#{name}"].split("\n")
  lines
    .map { |l| parse_commit_line(l) }
    .compact
    .reject { |i| i[:issue].match?(/(LIO-0+)/)  }
    .each { |i| issues.push i }
end

puts issues
  .sort { |a, b| b[:date] <=> a[:date]  }
  .map { |i| i[:issue] }
  .uniq
