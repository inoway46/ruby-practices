column_num = 3 # 出力時の列数
current_dir_files = Dir.glob("*").sort # ファイル一覧の読み込み
files_num = current_dir_files.size # ファイル数
max_str = current_dir_files.map(&:length).max + 2 # ファイル名の最大文字数

if files_num > column_num # 列数よりファイル数の方が多い場合は、垂直ソートしてから出力する
  # 列数に合わせてファイル名一覧の配列を分割
  if files_num % column_num  != 0
    split_length = (files_num / column_num ) + 1
  else
    split_length = files_num / column_num 
  end

  split_array = current_dir_files.each_slice(split_length).to_a

  # 垂直ソートした配列を生成
  ordered_files = []
  split_length.times do |i|
    column_num.times do |j|
      if !split_array[j].nil? && !split_array[j][i].nil?
        ordered_files << split_array[j][i]
      else
        ordered_files << ""
      end
    end
  end

  ordered_files.each_with_index do |file, idx|
    if (idx % column_num) == (column_num - 1) # 出力時に最終列で改行する
      print "#{file.to_s.ljust(max_str)}\n"
    else
      print "#{file.to_s.ljust(max_str)}"
    end
  end
else
  current_dir_files.each do |file|
    print "#{file.to_s.ljust(max_str)}"
  end
  print "\n" # 最終要素の出力後に改行する
end