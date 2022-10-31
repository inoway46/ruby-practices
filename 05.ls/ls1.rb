# frozen_string_literal: true

class ListSegment
  attr_reader :column_num, :dir

  def initialize(column_num = 3, pattern = '*')
    @column_num = column_num
    @dir = Dir.glob(pattern)
  end

  def output
    row_num = calc_row_num
    print_files(row_num)
  end

  private

  def mod
    @dir.size % @column_num
  end

  def calc_row_num
    (@dir.size / @column_num) + mod
  end

  def max_str(add_space = 2)
    @dir.map(&:length).max + add_space
  end

  def print_files(row_num)
    row_num.times do |row|
      column_num.times do |column|
        file = dir[column * row_num + row]
        break if file.nil?

        print file.to_s.ljust(max_str).to_s
      end
      print "\n"
    end
  end
end

ls = ListSegment.new
ls.output
