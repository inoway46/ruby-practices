# frozen_string_literal: true

require 'byebug'
require 'optparse'
require 'etc'
require 'date'
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

  def to_timestamp(stat)
    modified_time = stat.mtime.to_datetime
    today = DateTime.now
    half_year_ago = today - 180
    # 半年前〜現在時刻までの変更日時のファイルは時刻表示、それ以外は年表示
    today > modified_time && modified_time >= half_year_ago ? modified_time.strftime('%_m %_d %H:%M') : modified_time.strftime('%_m %_d %_Y')
  end

  def to_symlink_style(symlink)
    origin = File.readlink(symlink)
    "#{symlink} -> #{origin}"
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

  def count_max_nlink_digit(stats)
    stats.map(&:nlink).max.abs.to_s.size
  end

  def count_max_bitesize_digit(stats)
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
    max_nlink_digit = count_max_nlink_digit(@stats)
    max_bitesize_digit = count_max_bitesize_digit(@stats)
    @stats.each_with_index do |stat, index|
      print to_file_type_str(stat) # ファイルタイプ
      print to_permission_str(stat) # パーミッション
      print '  '
      printf("%#{max_nlink_digit}d", stat.nlink) # ハードリンク数
      print ' '
      print to_owner_name(stat) # オーナー名
      print '  '
      print to_group_name(stat) # グループ名
      print '  '
      printf("%#{max_bitesize_digit}d", stat.size) # バイトサイズ（最大値の桁数で右詰め）
      print ' '
      print to_timestamp(stat) # タイムスタンプ（最終更新時刻）
      print ' '
      file = @files[index]
      print stat.symlink? ? to_symlink_style(file) : file  # ファイル名
      print "\n"
    end
  end
end

opt = Option.new
ls = ListSegment.new(opt.options)
ls.output(opt.options)
