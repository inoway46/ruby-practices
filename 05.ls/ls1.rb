column_num = 3 # 出力列数
current_dir_files = Dir.glob("*").sort # ファイル一覧の読み込み
files_num = current_dir_files.size # ファイル数
max_str = current_dir_files.map(&:length).max + 2 # ファイル名の最大文字数
row_num = files_num / column_num # 出力行数

if files_num > column_num
  if files_num % column_num  != 0
    row_nums = Array.new(column_num, row_num)
    mod = files_num % column_num
    mod.times do |i|
      row_nums[i] = row_nums[i] + 1
    end
    row_num += 1
    pt = 0
    row_num.times do |row|
      column_num.times do |column|
        file = current_dir_files[row + pt]
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
        file = current_dir_files[row + pt]
        if column == (column_num - 1)
          print "#{file.to_s.ljust(max_str)}\n"
          pt = 0
        else
          print "#{file.to_s.ljust(max_str)}"
          pt += row_num
        end
      end
    end
  end
else
  current_dir_files.each do |file|
    print "#{file.to_s.ljust(max_str)}"
  end
  print "\n"
end
