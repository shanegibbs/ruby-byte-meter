#!/usr/bin/env ruby

require 'snmp'
require 'optparse'

options = {:host => nil, :interface => 3, :step => 1}

parser = OptionParser.new do|opts|
	opts.banner = 'Usage: ruby-byte-meter.rb [options]'
	opts.on('-t', '--target IP', 'Target host ip address') do |host|
		options[:host] = host;
	end

	opts.on('-i', '--interface INDEX', 'Interface index (default: 3)') do |interface|
		options[:interface] = interface;
	end

	opts.on('-s', '--step SECONDS', 'Step duration in seconds (default: 5)') do |step|
		options[:step] = step.to_i;
	end

	opts.on('-h', '--help', 'Displays Help') do
    puts opts
		exit
	end
end

parser.parse!

if options[:host].nil?
  $stderr.puts 'Missing target parameter'
  $stderr.puts parser
  exit -1
end

puts "Using host #{options[:host]}"
puts 'All metrics are in bytes'
puts

def get_counter(host, i)
  begin
    SNMP::Manager.open(:Host => host) do |snmp|
      arr = Array.new
      response = snmp.get(%w(IF-MIB::ifInOctets.#{i} IF-MIB::ifOutOctets.#{i}))
      response.each_varbind {|vb| arr.push vb.value.to_i}
      
      total = 0
      arr.each { |n| total += n }
      return total
    end
  rescue SNMP::RequestTimeout
    $stderr.print "Error: RequestTimeout\n"
  rescue Interrupt
    exit
  end
end

class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

interface = 3

t = Time.now.to_ms
counter = get_counter(options[:host], interface)
start_counter = counter
counter_last = counter

running = true
while running do
	t_last = t
	t = Time.now.to_ms
	t_diff = t - t_last
	
	if !counter.nil?
  	counter_last = counter
	end
	
	counter = get_counter(options[:host], interface)
	if !counter.nil? and !counter_last.nil?
	  diff = counter - counter_last
    
	  str = (diff).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
	  
	  bps = diff.to_f / (t_diff.to_f / 1000.0)
	  kbps = (bps / 1024.0)
	  kbps_str = kbps.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
	  
	  bar_max_size = 50
	  bar_top_mark = 1000 # (in KB)
	  
	  bar_size = ((kbps / bar_top_mark) * bar_max_size).to_i
	  bar_size = [0, [bar_size, bar_max_size].min].max
	  
	  bar = '|'.ljust bar_size, '-'
	  bar += '>' if bar_size > 0 and bar_size < bar_max_size
	  bar = bar.ljust(bar_max_size) + '|'

	  until_now = ((counter - start_counter) / 1024.0 / 1024.0)
	  	.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
	  
	  print "#{kbps_str.rjust(20)} KB/s #{bar} #{until_now} MB total\n"
	end
  
  begin
    sleep options[:step]
  rescue Interrupt
    running = false
  end

end
