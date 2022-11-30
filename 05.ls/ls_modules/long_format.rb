# frozen_string_literal: true

require_relative 'file_option'
require 'etc'
require 'date'

module ListSegment
  class LongFormat
    include FileOption

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

    def initialize(options = {})
      @options = options
      @files = sort_files(Dir.glob('*', to_fnm))
      @stats = to_stats(@files)
    end

    def output
      puts "total #{count_total_block_size}" # ブロックサイズの合計
      @stats.each_with_index do |stat, index|
        print to_file_type_str(stat) # ファイルタイプ
        print "#{to_permission_str(stat).ljust(9)}  " # パーミッション
        print "#{stat.nlink.to_s.rjust(count_max_nlink_digit(@stats))} " # ハードリンク数
        print "#{to_owner_name(stat).ljust(count_max_owner_name_str(@stats))}  " # オーナー名
        print "#{to_group_name(stat).ljust(count_max_group_name_str(@stats))}  " # グループ名
        print "#{stat.size.to_s.rjust(count_max_bitesize_digit(@stats))} " # バイトサイズ（最大値の桁数で右詰め）
        print "#{to_timestamp(stat)} " # タイムスタンプ（最終更新時刻）
        puts stat.symlink? ? to_symlink_style(@files[index]) : @files[index] # ファイル名
      end
    end

    private

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
end
