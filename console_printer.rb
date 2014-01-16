class ConsolePrinter

  attr_accessor :left_pad_speed

  def initialize(bar_max_size, bar_top_mark_kb)
    @bar_max_size = bar_max_size
    @bar_top_mark_kb = bar_top_mark_kb
    @left_pad_speed = 20
  end

  def print_speed(kbps)
    puts build_speed_string(kbps)
  end

  def build_speed_string(kbps)
    bar_size = ((kbps / @bar_top_mark_kb) * @bar_max_size).to_i
    bar_size = [0, [bar_size, @bar_max_size].min].max

    bar = '|'.ljust bar_size, '-'
    bar += '>' if bar_size > 0 and bar_size < @bar_max_size
    bar = bar.ljust(@bar_max_size) + '|'

    kbps_str = kbps.to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse

    # until_now = ((counter - start_counter) / 1024.0 / 1024.0)
    # .to_i.to_s.reverse.gsub(/(\d{3})(?=\d)/, '\\1,').reverse

    # print "#{kbps_str.rjust(20)} KB/s #{bar} #{until_now} MB total\n"
    return "#{kbps_str.rjust(@left_pad_speed)} KB/s #{bar}"
  end

end
