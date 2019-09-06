#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'base'

@holidays_cache = {}

def load_file(year)
  data = File.read("#{__dir__}/holidays/#{year}.json")
  JSON.parse(data, symbolize_names: true)
end

def holidays_by_year(year)
  return @holidays_cache[year] unless @holidays_cache[year].nil?

  puts 'No cache available, reading file'
  @holidays_cache[year] =
    load_file(year)
    .map { |d| Date.strptime d[:date], '%d/%m/%Y' }
    .uniq
end

def holidays_by_month(year, month)
  key = "#{year}_#{month}"
  return @holidays_cache[key] unless @holidays_cache[key].nil?

  @holidays_cache[key] = holidays_by_year(year).select { |d| d.month == month }
end

def holiday?(date)
  holidays_by_month(date.year, date.month).include? date
end

return unless $PROGRAM_NAME == __FILE__

begin
  p holidays_by_month ARGV[0].to_i, ARGV[1].to_i
  puts "Is today a holiday? #{holiday?(Date.today)}"
rescue StandardError
  puts "Usage: #{$PROGRAM_NAME} year month"
end
