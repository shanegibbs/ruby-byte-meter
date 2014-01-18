require 'minitest/autorun'
require 'minitest/pride'

require 'rbm'

class CounterTest < Minitest::Unit::TestCase

  def test_exception_if_no_override

    assert_raises RuntimeError do
      RubyByteMeter::Counter.new.get_value
    end

  end

end
