# frozen_string_literal: true

require 'optparse'

class Option
  attr_reader :options

  def initialize
    @options = {}
    OptionParser.new do |option|
      option.on('-a') { |v| @options[:select_all_files] = v }
      option.parse!(ARGV)
    end
  end
end

class ListSegment
  attr_reader :options, :column_num, :dir

  def initialize(options = {}, column_num = 3)
    @options = options
    @column_num = column_num
    @dir = fetch_file_names
  end

  def output
    row_num = calc_row_num
    print_files(row_num)
  end

  private

  def fetch_file_names
    if options[:select_all_files]
      Dir.entries(Dir.pwd).sort
    else
      Dir.glob('*').sort
    end
  end

  def mod
    @dir.size % @column_num
  end

  def calc_row_num
    (@dir.size / @column_num) + mod
  end

  def max_str(add_space = 2)
    @dir.map(&:length).max + add_space
  end

  def print_files(row_num)
    row_num.times do |row|
      column_num.times do |column|
        file = dir[column * row_num + row]
        break if file.nil?

        print file.to_s.ljust(max_str).to_s
      end
      print "\n"
    end
  end
end

opt = Option.new
ls = ListSegment.new(opt.options)
ls.output
