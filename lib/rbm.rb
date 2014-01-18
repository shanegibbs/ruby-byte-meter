require 'rbm/cli_options'
require 'rbm/console_printer'
require 'rbm/counter'
require 'rbm/snmp_counter'

require 'rbm/app'

module RubyByteMeter
end


# TODO remove me
class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end
