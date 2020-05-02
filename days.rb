#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'holidays'

def work_days(year, month)
  start_date = Date.new(year, month, 1)
  end_date = Date.new(year, month, -1)

  start_date.upto(end_date)
            .reject { |d| d.sunday? || d.saturday? || holiday?(d) }
end

return unless $PROGRAM_NAME == __FILE__

puts work_days ARGV[0].to_i, ARGV[1].to_i
