require 'minitest/autorun'
require 'minitest/pride'

require 'console_printer'

class ConsolePrinterTest < Minitest::Unit::TestCase

  def setup
    @under_test = ConsolePrinter.new 10, 1000
    @under_test.left_pad_speed = 10
  end

  def teardown
  end

  def test_build_speed_string

    expected = '       500 KB/s |---->    |'
    actual = @under_test.build_speed_string 500.0

    assert_equal expected, actual

  end
end
