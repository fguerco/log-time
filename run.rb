#!/usr/bin/env ruby

require_relative 'my-issues'
require_relative 'log-work'
require_relative 'days'

year = ARGV[0].to_i
month = ARGV[1].to_i
extras = ARGV[2]

puts extras

only = []
except = []

unless extras.nil?
  sep = extras.split('=')
  rule = sep[0]
  data = sep[1]

  if rule == 'only'
    only.push(*data.split(','))
  elsif rule == 'except'
    except.push(*data.split(','))
  end
end

issues_worked = my_issues(year, month)
work_days = work_days(year, month)

issues_per_day = (issues_worked.size / work_days.size.to_f).floor(1)

HOURS_PER_DAY = 8
HOURS_PER_ISSUE = (HOURS_PER_DAY / issues_per_day).ceil
STARTING_HOUR = 9

puts "issues to log: #{issues_worked.size}"
puts "work days: #{work_days.size}"
puts "hours per issue: #{HOURS_PER_ISSUE}"

issues_to_log = issues_worked
  .map do |i|
    {
      issue: i,
      hours_left: HOURS_PER_ISSUE
    }
  end

next_issue = issues_to_log.shift

filtered_days =
  work_days
  .reject { |d| except.include?(d.day.to_s)  }
  .select { |d| only.empty? || only.include?(d.day.to_s) }

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

    log_work(next_issue[:issue], date_log.to_s, "#{hours}h")
    logged += hours

    next_issue = issues_to_log.shift if next_issue[:hours_left] == 0
  end

end
