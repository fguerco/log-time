#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

def format_date(date)
  date.strftime('%Y-%m-%d')
end

def parse_commit_line(line)
  m = line.match(/(\d{4}-\d{2}-\d{2})(?:.*)(LIO-\d+)/)
  return nil if m.nil?

  { date: m[1], issue: m[2] }
end

def commits_from_repository(start_date, end_date)
  name = `git config user.name`.chomp
  `git log \
     --date=iso \
     --format="%ad %s" \
     --no-merges \
     --all \
     --after="#{format_date(start_date)}" \
     --until="#{format_date(end_date)}" \
     --author="#{name}"`
    .split("\n")
end

def parse_commits(commits)
  commits
    .map { |l| parse_commit_line(l) }
    .compact
    .reject { |i| i[:issue].match?(/(LIO-0+)/) }
end

def sort_and_clean(issues)
  issues
    .sort { |a, b| b[:date] <=> a[:date] }
    .map { |i| i[:issue] }
    .uniq
end

def my_issues(year, month)
  issues = []

  start_date = Date.new(year, month, 1)
  end_date = Date.new(year, month, -1)

  projects = `find #{CONFIG[:projects_dir]} -name '.git' -type d`.split.map { |d| File.dirname(d) }
  projects.each do |path|
    Dir.chdir path
    repo_commits = commits_from_repository(start_date, end_date)
    issues.push(*parse_commits(repo_commits))
  end

  sort_and_clean issues
end

return unless $PROGRAM_NAME == __FILE__

begin
  p my_issues ARGV[0].to_i, ARGV[1].to_i
rescue StandardError
  puts "Usage: #{$PROGRAM_NAME} year month"
end
