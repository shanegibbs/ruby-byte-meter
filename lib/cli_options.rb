require 'optparse'
require 'ostruct'

class CliOptions

  def self.parse(args)
    options = OpenStruct.new
    options.host = nil
    options.interface = 3
    options.step = 1

    opt_parser = OptionParser.new do|opts|
      opts.banner = 'Usage: rbm.rb [options]'

      opts.separator ''
      opts.separator 'NOTE: All metrics displayed are in bytes'
      opts.separator ''
      opts.separator 'Common options:'

      opts.on('-t', '--target IP', 'Target host ip address') do |host|
        options.host = host;
      end

      opts.on('-i', '--interface INDEX', 'Interface index (default: 3)') do |interface|
        options.interface = interface;
      end

      opts.on('-s', '--step SECONDS', 'Step duration in seconds (default: 5)') do |step|
        options.step = step.to_i;
      end

      opts.on('-h', '--help', 'Show this message') do
        puts ''
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)

    if options.host.nil?
      $stderr.puts 'ERROR: Missing target parameter'
      $stderr.puts opt_parser
      exit -1
    end

    options
  end

end
