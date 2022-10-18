# frozen_string_literal: true

class ListSegment
  attr_accessor :dir, :column_num, :row_num, :row_nums

  def initialize(column_num = 3, pattern = '*')
    @column_num = column_num
    @dir = Dir.glob(pattern)
    @row_num = size / @column_num
    @row_nums = Array.new(@column_num, @row_num)
  end

  def size
    @dir.size
  end

  def add_row(add = 1)
    @row_num = row_num + add
  end

  def max_str(add_space = 2)
    @dir.map(&:length).max + add_space
  end

  def mod
    size % @column_num
  end

  def update_row_nums
    mod.times do |i|
      row_nums[i] = row_nums[i] + 1
    end
    add_row
  end

  def print_multiline(leap_num = 0)
    row_num.times do |row|
      column_num.times do |column|
        file = dir[row + leap_num]
        if column == (column_num - 1)
          print "#{file.to_s.ljust(max_str)}\n"
          leap_num = 0
        else
          print file.to_s.ljust(max_str).to_s
          leap_num += row_nums[column]
          if mod != 0 && row == (row_num - 1) && column == (mod - 1)
            print "\n"
            break
          end
        end
      end
    end
  end

  def print_oneline
    dir.each do |file|
      print file.to_s.ljust(max_str).to_s
    end
    print "\n"
  end

  def output
    if size > column_num
      update_row_nums if mod != 0
      print_multiline
    else
      print_oneline
    end
  end

  ls = ListSegment.new
  ls.output
end
