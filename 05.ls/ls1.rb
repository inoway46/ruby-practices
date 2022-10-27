# frozen_string_literal: true

class ListSegment
  attr_reader :column_num, :dir

  def initialize(column_num = 3, pattern = '*')
    @column_num = column_num
    @dir = Dir.glob(pattern)
  end

  def output
    row_nums = generate_row_nums(calc_row_num)
    print_files(row_nums)
  end

  private

  def size
    @dir.size
  end

  def mod
    size % @column_num
  end

  def calc_row_num
    size / @column_num
  end

  def generate_row_nums(row_num)
    row_nums = Array.new(@column_num, row_num)
    mod.times do |i|
      row_nums[i] = row_nums[i] + 1
    end
    row_nums
  end

  def max_str(add_space = 2)
    @dir.map(&:length).max + add_space
  end

  def print_files(row_nums)
    row_num = row_nums.first
    row_num.times do |row|
      leap_num = 0
      column_num.times do |column|
        file = dir[row + leap_num]
        print file.to_s.ljust(max_str).to_s
        leap_num += row_nums[column]
        break if row == (row_num - 1) && column == (mod - 1)
      end
      print "\n"
    end
  end
end

ls = ListSegment.new
ls.output
