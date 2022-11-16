# frozen_string_literal: true

require 'byebug'
require 'optparse'
require 'etc'
NO_FILE_OPTION = 0

class Option
  attr_reader :options

  def initialize
    @options = {}
    OptionParser.new do |option|
      option.on('-a') { |v| @options[:select_all_files] = v }
      option.on('-l') { |v| @options[:long_format] = v }
      option.on('-r') { |v| @options[:reverse_sort] = v }
      option.parse!(ARGV)
    end
  end
end

class ListSegment
  def initialize(options = {}, column_num = 3)
    @column_num = set_column_num(column_num, options)
    @files = sort_files(Dir.glob('*', to_fnm(options)), options)
    @stats = to_stats(@files) if options[:long_format]
  end

  def output(options)
    if options[:long_format]
      output_files_in_long_format
    else
      row_num = calc_row_num
      output_files(row_num)
    end
  end

  private

  def set_column_num(column_num, options)
    options[:long_format] ? 1 : column_num
  end

  def to_fnm(options)
    options[:select_all_files] ? File::FNM_DOTMATCH : NO_FILE_OPTION
  end

  def to_stats(files)
    files.map { |file| File.lstat(file) }
  end

  def to_file_type_str(stat)
    file_types = { 'file' => '-', 'directory' => 'd', 'link' => 'l' }
    file_types[stat.ftype]
  end

  def to_permission_str(stat)
    permit_array = (stat.mode.to_s(8).to_i % 1000).to_s.split('')
    permit_array.map { |octal| to_ls_permission_style(octal) }.join
  end

  def to_ls_permission_style(octal)
    permission_patterns = {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }
    permission_patterns[octal]
  end

  def to_owner_name(stat)
    Etc.getpwuid(stat.uid).name
  end

  def to_group_name(stat)
    Etc.getgrgid(stat.gid).name
  end

  def sort_files(files, options)
    options[:reverse_sort] ? files.sort.reverse : files.sort
  end

  def mod
    @files.size % @column_num
  end

  def calc_row_num
    (@files.size / @column_num) + mod
  end

  def calc_total_block_size
    @stats.map(&:blocks).inject(:+)
  end

  def max_str(add_space = 2)
    @files.map(&:length).max + add_space
  end

  def count_max_digit(stats)
    stats.map(&:size).max.abs.to_s.size
  end

  def output_files(row_num)
    row_num.times do |row|
      @column_num.times do |column|
        file = @files[column * row_num + row]
        break if file.nil?

        print file.to_s.ljust(max_str).to_s
      end
      print "\n"
    end
  end

  def output_files_in_long_format
    puts "total #{calc_total_block_size}" # ブロックサイズの合計
    max_digit = count_max_digit(@stats)
    @stats.each do |stat|
      print to_file_type_str(stat) # ファイルタイプ
      print to_permission_str(stat) # パーミッション
      print '  '
      print stat.nlink # ハードリンク数
      print ' '
      print to_owner_name(stat) # オーナー名
      print '  '
      print to_group_name(stat) # グループ名
      print '  '
      printf("%#{max_digit}d", stat.size) # バイトサイズ（最大値の桁数で右詰め）
      print ' '
      print "\n"
    end
  end
end

opt = Option.new
ls = ListSegment.new(opt.options)
ls.output(opt.options)
