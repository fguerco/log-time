#!/usr/bin/env ruby

require_relative 'holidays'

def work_days(year, month)
  start_date = Date.new(year, month, 1)
  end_date = Date.new(year, month, -1)

  end_date.downto(start_date)
    .reject { |d| d.sunday? || d.saturday? || is_holiday?(d) }

end

return unless __FILE__ == $0

puts work_days ARGV[0].to_i, ARGV[1].to_i
