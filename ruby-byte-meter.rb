#!/usr/bin/env ruby

require 'snmp'
require 'optparse'

options = {:host => nil, :interface => 3, :step => 5}

parser = OptionParser.new do|opts|
	opts.banner = "Usage: test.rb [options]"
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

raise OptionParser::MissingArgument if options[:host].nil?

puts "Using host #{options[:host]}"
puts "All metrics are in bytes"
puts

def getCounter(host, i)
  begin
    SNMP::Manager.open(:Host => host) do |snmp|
      arr = Array.new
      response = snmp.get(["IF-MIB::ifInOctets.#{i}", "IF-MIB::ifOutOctets.#{i}"])
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
counter = getCounter(options[:host], interface)
startCounter = counter

running = true
while running do
	tLast = t;
	t = Time.now.to_ms
	tDiff = t - tLast
	
	if !counter.nil?
  	counterLast = counter
	end
	
	counter = getCounter(options[:host], interface)
	if !counter.nil? and !counterLast.nil?
	  diff = counter - counterLast
    
	  str = (diff).to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
	  
	  bps = diff.to_f / (tDiff.to_f / 1000.0)
	  kbps = (bps / 1024.0)
	  kbpsStr = kbps.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
	  
	  barMaxSize = 50;
	  barTopMark = 1000 # (in KB)
	  
	  barSize = ((kbps / barTopMark) * barMaxSize).to_i
	  barSize = [0, [barSize, barMaxSize].min].max
	  
	  bar = "|".ljust barSize, "-"
	  bar += ">" if barSize > 0 and barSize < barMaxSize
	  bar = bar.ljust(barMaxSize) + "|"

	  untilNow = ((counter - startCounter) / 1024.0 / 1024.0)
	  	.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse
	  
	  print "#{kbpsStr.rjust(20)} KB/s #{bar} #{untilNow} MB total\n"
	end
  
  begin
    sleep options[:step]
  rescue Interrupt
    running = false
  end

end
