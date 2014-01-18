require 'minitest/autorun'
require 'minitest/pride'

require 'counter'

class CounterTest < Minitest::Unit::TestCase

  def test_exception_if_no_override

    assert_raises RuntimeError do
      Counter.new.get_value
    end

  end

end
