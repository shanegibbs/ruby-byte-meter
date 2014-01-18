require 'snmp'

require_relative 'counter'

module RubyByteMeter

  class SnmpCounter < Counter

    def initialize(host, interface)
      @host = host
      @interface = interface
    end

    def get_value
      begin
        SNMP::Manager.open(:Host => @host) do |snmp|
          arr = Array.new
          response = snmp.get(["IF-MIB::ifInOctets.#{@interface}", "IF-MIB::ifOutOctets.#{@interface}"])
          response.each_varbind { |vb| arr.push vb.value.to_i }

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

  end

end
