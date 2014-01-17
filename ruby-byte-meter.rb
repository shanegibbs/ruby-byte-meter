#!/usr/bin/env ruby

require_relative 'cli_options'
require_relative 'snmp_counter'
require_relative 'console_printer'

options = CliOptions.parse ARGV

puts "Using host #{options[:host]}"
puts

class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

interface = 3

counter = SnmpCounter.new options[:host], interface

t = Time.now.to_ms
counter_value = counter.get_value
start_counter = counter_value
counter_value_last = counter_value

bar_max_size = 50
bar_top_mark = 10000 # (in KB)

printer = ConsolePrinter.new bar_max_size, bar_top_mark

running_overhead = 0

running = true
while running do

  if !counter_value.nil?
    counter_value_last = counter_value
  end
  counter_value = counter.get_value

  t_last = t
  t = Time.now.to_ms
  t_diff = t - t_last
  t_diff_secs = t_diff.to_f / 1000.0

  if !counter_value.nil? and !counter_value_last.nil?
    diff = counter_value - counter_value_last

    bps = diff.to_f / t_diff_secs
    kbps = (bps / 1024.0)

    printer.print_speed kbps

  end

  begin

    overhead = t_diff_secs - options.step

    # add 20% of the current overhead to the running overhead
    # this "should" get smaller
    running_overhead += overhead / 5

    sleep_time = [options.step - running_overhead, options.step].min

    sleep sleep_time if sleep_time > 0
  rescue Interrupt
    running = false
  end

end
