array = Dir.glob("*").sort

count = array.size

if count%3 != 0
  num = count/3 + 1
else
  num = count/3
end

array2 = array.each_slice(num).to_a

files = []
num.times do |i|
  3.times do |j|
    if !array2[j][i].nil?
      files << array2[j][i]
    else
      files << ""
    end
  end
end

files.each_with_index do |file, i|
  if i%3 == 2
    print "#{file.to_s.ljust(10)}\n"
  else
    print file.to_s.ljust(10)
  end
end
