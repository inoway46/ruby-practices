class ListSegment
  attr_accessor :dir, :column_num, :row_num, :row_nums

  def initialize(column_num, pattern="*")
    @column_num = column_num
    @dir = Dir.glob(pattern)
    @row_num = size / @column_num
    @row_nums = Array.new(@column_num, @row_num)
  end

  def size
    @dir.size
  end

  def add_row(add=1)
    @row_num = row_num + add
  end

  def max_str(add_space=2)
    @dir.map(&:length).max + add_space
  end

  def mod
    size % @column_num
  end

  def update_row_nums
    mod.times do |i|
      row_nums[i] = row_nums[i] + 1
    end
  end

  def print_oneline
    dir.each do |file|
      print "#{file.to_s.ljust(max_str)}"
    end
    print "\n"
  end

  def output
    if size > column_num
      if mod != 0
        update_row_nums
        add_row
        pt = 0
        row_num.times do |row|
          column_num.times do |column|
            file = dir[row + pt]
            if column == (column_num - 1)
              print "#{file.to_s.ljust(max_str)}\n"
              pt = 0
            else
              print "#{file.to_s.ljust(max_str)}"
              pt += row_nums[column]
              if row == (row_num - 1) && column == (mod - 1)
                print "\n"
                break
              end
            end
          end
        end
      else
        pt = 0
        row_num.times do |row|
          column_num.times do |column|
            file = dir[row + pt]
            if column == (column_num - 1)
              print "#{file.to_s.ljust(max_str)}\n"
              pt = 0
            else
              print "#{file.to_s.ljust(max_str)}"
              pt += row_nums[column]
            end
          end
        end
      end
    else
      print_oneline
    end    
  end
end
