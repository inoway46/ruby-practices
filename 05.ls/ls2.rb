# frozen_string_literal: true

class ListSegment
  attr_reader :column_num, :dir, :size, :mod, :row_num, :row_nums

  def initialize(option = '', column_num = 3)
    @column_num = column_num
    @dir = fetch_file_names(option)
    @size = @dir.size
    @mod = size % @column_num
    @row_num = size / @column_num
    @row_nums = Array.new(@column_num, @row_num)
  end

  def output
    update_row_nums if mod != 0
    print_files
  end

  private

  def fetch_file_names(option)
    case option
    when '-a'
      Dir.entries(Dir.pwd).sort
    else
      Dir.glob('*').sort
    end
  end

  def max_str(add_space = 2)
    @dir.map(&:length).max + add_space
  end

  def update_row_nums
    mod.times do |i|
      row_nums[i] = row_nums[i] + 1
    end
    @row_num = row_num + 1
  end

  def print_files(leap_num = 0)
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
end

def ls(option = '')
  ls = ListSegment.new(option)
  ls.output
end

ls(ARGV[0])
