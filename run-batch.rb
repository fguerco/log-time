#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'

require_relative 'base'
require_relative 'log-work'
require_relative 'days'

file = ARGV[0] || 'data.yml'
data = YAML.safe_load(File.read("#{__dir__}/#{file}"))

PRODUCTION = ENV['production'] || false

HOURS_PER_DAY = 8
STARTING_HOUR = 9

YEAR = data['year']
MONTH = data['month']
ITEMS = data['items']

last_day = Date.new(YEAR, MONTH, -1).day
wdays = work_days(YEAR, MONTH).map(&:day)

last_issues = nil
issues = nil

1.upto(last_day) do |day|
  logged = 0
  minute = 0
  issues = ITEMS[day] if ITEMS.key?(day)
  next unless wdays.any?(day) && !issues.nil?

  last_issues = issues if issues != last_issues

  issues_array = issues.split(',')
  hours_ref = HOURS_PER_DAY / issues_array.size
  total_ref = hours_ref * (issues_array.size - 1)
  corrected_hours = HOURS_PER_DAY - total_ref

  issues_array.each.with_index do |issue, index|
    hours = index.zero? ? corrected_hours : hours_ref
    date_log = Time.new(YEAR, MONTH, day, STARTING_HOUR + logged, minute)
    minute += 10
    log_work(issue, date_log.to_s, "#{hours}h", PRODUCTION)
    logged += hours
  end
end
