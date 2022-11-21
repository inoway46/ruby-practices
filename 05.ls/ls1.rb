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

module LongFormat
  module Converter
    PERMISSION_PATTERNS = {
      '0' => '---',
      '1' => '--x',
      '2' => '-w-',
      '3' => '-wx',
      '4' => 'r--',
      '5' => 'r-x',
      '6' => 'rw-',
      '7' => 'rwx'
    }.freeze

    UID_PERMISSION_PATTERNS = {
      '0' => '--S',
      '1' => '--s',
      '2' => '-wS',
      '3' => '-ws',
      '4' => 'r-S',
      '5' => 'r-s',
      '6' => 'rwS',
      '7' => 'rws'
    }.freeze

    STICKY_PERMISSION_PATTERNS = {
      '0' => '--T',
      '1' => '--t',
      '2' => '-wT',
      '3' => '-wt',
      '4' => 'r-T',
      '5' => 'r-t',
      '6' => 'rwT',
      '7' => 'rwt'
    }.freeze

    def to_stats(files)
      files.map { |file| File.lstat(file) }
    end

    def to_file_type_str(stat)
      file_types = { 'file' => '-', 'directory' => 'd', 'link' => 'l' }
      file_types[stat.ftype]
    end

    def to_permission_str(stat)
      permit_array = (stat.mode.to_s(8).to_i % 1000).to_s.chars
      owner_permittion_octal, group_permittion_octal, other_permittion_octal = permit_array

      owner = stat.setuid? ? to_uid_permission_style(owner_permittion_octal) : to_permission_style(owner_permittion_octal)
      group = stat.setgid? ? to_uid_permission_style(group_permittion_octal) : to_permission_style(group_permittion_octal)
      other = stat.sticky? ? to_sticky_permission_style(other_permittion_octal) : to_permission_style(other_permittion_octal)
      owner + group + other
    end

    def to_permission_style(octal)
      PERMISSION_PATTERNS[octal]
    end

    def to_uid_permission_style(octal)
      UID_PERMISSION_PATTERNS[octal]
    end

    def to_sticky_permission_style(octal)
      STICKY_PERMISSION_PATTERNS[octal]
    end

    def to_owner_name(stat)
      Etc.getpwuid(stat.uid).name
    end

    def to_group_name(stat)
      Etc.getgrgid(stat.gid).name
    end

    def to_timestamp(stat)
      modification_time = stat.mtime.to_datetime
      today = DateTime.now
      half_year_ago = today - 180
      # 半年前〜現在時刻までの変更日時のファイルは時刻表示、それ以外は年表示
      today > modification_time && modification_time >= half_year_ago ? modification_time.strftime('%_m %_d %H:%M') : modification_time.strftime('%_m %_d %_Y')
    end

    def to_symlink_style(symlink)
      origin = File.readlink(symlink)
      "#{symlink} -> #{origin}"
    end
  end

  module Counter
    def count_total_block_size
      @stats.map(&:blocks).sum
    end

    def count_max_owner_name_str(stats)
      stats.map { |stat| to_owner_name(stat).length }.max
    end

    def count_max_group_name_str(stats)
      stats.map { |stat| to_group_name(stat).length }.max
    end

    def count_max_nlink_digit(stats)
      stats.map(&:nlink).max.abs.to_s.size
    end

    def count_max_bitesize_digit(stats)
      stats.map(&:size).max.abs.to_s.size
    end
  end

  module Output
    def output_files_in_long_format
      puts "total #{count_total_block_size}" # ブロックサイズの合計
      @stats.each_with_index do |stat, index|
        print to_file_type_str(stat) # ファイルタイプ
        print "#{to_permission_str(stat).ljust(9)}  " # パーミッション
        print stat.mode.to_s(8)
        print "#{stat.nlink.to_s.rjust(count_max_nlink_digit(@stats))} " # ハードリンク数
        print "#{to_owner_name(stat).ljust(count_max_owner_name_str(@stats))}  " # オーナー名
        print "#{to_group_name(stat).ljust(count_max_group_name_str(@stats))}  " # グループ名
        print "#{stat.size.to_s.rjust(count_max_bitesize_digit(@stats))} " # バイトサイズ（最大値の桁数で右詰め）
        print "#{to_timestamp(stat)} " # タイムスタンプ（最終更新時刻）
        puts stat.symlink? ? to_symlink_style(@files[index]) : @files[index]  # ファイル名
      end
    end
  end
end

class ListSegment
  include LongFormat::Converter
  include LongFormat::Counter
  include LongFormat::Output

  def initialize(options = {}, column_num = 3)
    @options = options
    @column_num = column_num
    @files = sort_files(Dir.glob('*', to_fnm))
    @stats = to_stats(@files) if options[:long_format]
  end

  def output
    @options[:long_format] ? output_files_in_long_format : output_files
  end

  private

  def to_fnm
    @options[:select_all_files] ? File::FNM_DOTMATCH : NO_FILE_OPTION
  end

  def sort_files(files)
    @options[:reverse_sort] ? files.sort.reverse : files.sort
  end

  def mod
    @files.size % @column_num
  end

  def calc_row_num
    (@files.size / @column_num) + mod
  end

  def count_max_file_name_str(add_space = 2)
    @files.map(&:length).max + add_space
  end

  def output_files
    row_num = calc_row_num
    row_num.times do |row|
      @column_num.times do |column|
        file = @files[column * row_num + row]
        break if file.nil?

        print file.to_s.ljust(count_max_file_name_str).to_s
      end
      print "\n"
    end
  end
end

opt = Option.new
ls = ListSegment.new(opt.options)
ls.output
