#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'my-issues'
require_relative 'log-work'
require_relative 'days'
require 'slop'

opts = Slop.parse do |o|
  o.integer '-y', '--year', 'Year of work done. Mandatory'
  o.integer '-m', '--month', 'Month of work done. Mandatory'
  o.string '-o', '--only', 'Only specified days - comma separated. Optional'
  o.string '-e', '--except', 'Except specified days - comma separated. Optional'
  o.string '-i', '--issues', 'Use specified issues instead of project repositories'
  o.bool '-p', '--production', 'Run in production mode. Will only update work log if set. Optional', default: false
  o.bool '-h', '--help', 'Show help'
end

year = opts[:year]
month = opts[:month]
production = opts.production?

def show_help?(opts)
  opts.help? || opts[:year].nil? || opts[:month].nil?
end

if show_help?(opts)
  puts opts
  exit
end

def arg_as_array(arg)
  arg.nil? ? [] : arg.split(',')
end

if production
  print 'Running in production mode. This program will register work logs. Continue (y/N)? '
  r = STDIN.gets.chomp
  exit unless r.downcase == 'y'
else
  puts 'Not running in production mode. This program will only show what will be done. '\
    'To run in production mode execute:', '',
       "#{$PROGRAM_NAME} -p #{ARGV.join(' ')}", ''
end

only = arg_as_array(opts[:only])
except = only.any? ? [] : arg_as_array(opts[:except])
issues = arg_as_array(opts[:issues])

issues_worked = issues.empty? ? my_issues(year, month) : issues
work_days = work_days(year, month)

filtered_days =
  work_days
  .reject { |d| except.include?(d.day.to_s) }
  .select { |d| only.empty? || only.include?(d.day.to_s) }

issues_per_day = (issues_worked.size / work_days.size.to_f).floor(1).to_i
issues_per_day = issues_worked.size if issues_per_day.zero?

HOURS_PER_DAY = 8
STARTING_HOUR = 9
TOTAL_HOURS = HOURS_PER_DAY * filtered_days.size
HOURS_PER_ISSUE_WORKED = (TOTAL_HOURS / issues_worked.size.to_f).ceil
MIN_HOURS_PER_ISSUE = HOURS_PER_DAY / 2
HOURS_PER_ISSUE = [(HOURS_PER_DAY / issues_per_day).ceil, MIN_HOURS_PER_ISSUE, HOURS_PER_ISSUE_WORKED].max

puts "issues to log: #{issues_worked.size}"
puts "days to log: #{filtered_days.size}"
puts "hours per issue: #{HOURS_PER_ISSUE}"

issues_to_log = issues_worked
                .map do |i|
  {
    issue: i,
    hours_left: HOURS_PER_ISSUE
  }
end

next_issue = issues_to_log.shift

filtered_days.each do |d|
  puts "\n", '-' * 80, "Logging work for #{d}:"

  minute = 0
  logged = 0

  while logged < HOURS_PER_DAY
    pending = HOURS_PER_DAY - logged

    hours = next_issue[:hours_left]
    hours = pending if hours > pending
    next_issue[:hours_left] -= hours
    pending -= hours

    date_log = Time.new(d.year, d.month, d.day, STARTING_HOUR + logged, minute)
    minute += 10

    log_work(next_issue[:issue], date_log.to_s, "#{hours}h", production)
    logged += hours

    next_issue = issues_to_log.shift if next_issue[:hours_left].zero?
  end
end
