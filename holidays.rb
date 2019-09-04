#!/usr/bin/env ruby

require_relative 'base'

HOLIDAYS_CACHE = {}

# HOLIDAYS_ENDPOINT = "https://api.calendario.com.br/?json=true&ano=#{year}&ibge=3304557&token=#{CONFIG[:calendar_api_token]}"

def holidays_by_year(year)
  return HOLIDAYS_CACHE[year] unless HOLIDAYS_CACHE[year].nil?

  HOLIDAYS_CACHE[year] = JSON.parse(File.read("#{__dir__}/holidays/#{year}.json"), symbolize_names: true)
    .map { |d| Date.strptime d[:date], '%d/%m/%Y' }
    .uniq
end

def holidays_by_month(year, month)
  key = "#{year}_#{month}"
  return HOLIDAYS_CACHE[key] unless HOLIDAYS_CACHE[key].nil?
  HOLIDAYS_CACHE[key] = holidays_by_year(year).select { |d| d.month == month }
end

def is_holiday?(date)
  holidays_by_month(date.year, date.month).include? date
end

return unless __FILE__ == $0

begin
  p holidays_by_month ARGV[0].to_i, ARGV[1].to_i
  puts "Is today a holiday? #{is_holiday?(Date.today)}"
rescue
  puts "Usage: #{$0} year month"
end
