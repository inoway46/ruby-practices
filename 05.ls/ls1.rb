# frozen_string_literal: true

require 'optparse'
NO_FILE_OPTION = 0

class Option
  attr_reader :options

  def initialize
    @options = {}
    OptionParser.new do |option|
      option.on('-a') { |v| @options[:select_all_files] = v }
      option.on('-r') { |v| @options[:reverse_sort] = v }
      option.parse!(ARGV)
    end
  end
end

class ListSegment
  def initialize(options = {}, column_num = 3)
    @column_num = column_num
    @files = sort_files(Dir.glob('*', to_fnm(options)), options)
  end

  def output
    row_num = calc_row_num
    print_files(row_num)
  end

  private

  def to_fnm(options)
    options[:select_all_files] ? File::FNM_DOTMATCH : NO_FILE_OPTION
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

  def max_str(add_space = 2)
    @files.map(&:length).max + add_space
  end

  def print_files(row_num)
    row_num.times do |row|
      @column_num.times do |column|
        file = @files[column * row_num + row]
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
