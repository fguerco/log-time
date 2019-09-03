#!/usr/bin/env ruby

require_relative 'base'

# HOLIDAYS_ENDPOINT = "https://api.calendario.com.br/?json=true&ano=#{year}&ibge=3304557&token=ZmVsaXBlLm9saXZlaXJhQG00dS5jb20uYnImaGFzaD05NTYyMzc3OQ"

def get_holidays_of(year)
  data = JSON.parse(File.read("holidays/#{year}.json"), symbolize_names: true)
  data
    .map { |d| Date.strptime d[:date], '%d/%m/%Y' }
    .uniq
end

puts get_holidays_of 2019
