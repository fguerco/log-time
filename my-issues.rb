#!/usr/bin/env ruby

require_relative 'base'

def format_date(date)
  date.strftime('%Y-%m-%d')
end

def parse_commit_line(line)
  m = line.match(/(\d{4}-\d{2}-\d{2})(?:.*)(LIO-\d+)/)
  return nil if m.nil?
  { date: m[1], issue: m[2] }
end

def my_issues(year, month)
  issues = []

  start_date = Date.new(year, month, 1)
  end_date = Date.new(year, month, -1)

  projects = %x[find #{CONFIG[:projects_dir]} -name '.git' -type d].split.map { |d| File.dirname(d) }
  projects.each do |path|
    Dir.chdir path
    name = %x[git config user.name]
    lines = %x[git log --date=iso --format="%ad %s" --all --after="#{format_date(start_date)}" --until="#{format_date(end_date)}" --author="#{name}"].split("\n")
    lines
      .map { |l| parse_commit_line(l) }
      .compact
      .reject { |i| i[:issue].match?(/(LIO-0+)/)  }
      .each { |i| issues.push i }
  end

  issues
    .sort { |a, b| b[:date] <=> a[:date]  }
    .map { |i| i[:issue] }
    .uniq
end

return unless __FILE__ == $0

begin
  p my_issues ARGV[0].to_i, ARGV[1].to_i
rescue
  puts "Usage: #{$0} year month"
end
