current_dir_files = Dir.glob("*").sort

files_num = current_dir_files.size

if files_num % 3 != 0
  split_length = (files_num / 3) + 1
else
  split_length = files_num / 3
end

split_array = current_dir_files.each_slice(split_length).to_a

ordered_files = []

if files_num > 3
  split_length.times do |i|
    3.times do |j|
      if !split_array[j][i].nil?
        ordered_files << split_array[j][i]
      else
        ordered_files << ""
      end
    end
  end
else
  ordered_files = current_dir_files
end

max_str = ordered_files.map(&:length).max + 2

ordered_files.each_with_index do |file, idx|
  if idx % 3 == 2 || (files_num - 1) == idx
    print "#{file.to_s.ljust(max_str)}\n"
  else
    print "#{file.to_s.ljust(max_str)}"
  end
end
