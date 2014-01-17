require 'minitest/autorun'

require_relative 'counter'

class CounterTest < Minitest::Test

  def test_exception_if_no_override

    assert_raises RuntimeError do
      Counter.new.get_value
    end

  end

end
