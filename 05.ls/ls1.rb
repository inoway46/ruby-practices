# frozen_string_literal: true

require 'optparse'
NO_OPTION = 0

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
  def initialize(options = {}, column_num = 3)
    @column_num = column_num
    @files = Dir.glob('*', to_fnm(options)).sort
  end

  def output
    row_num = calc_row_num
    print_files(row_num)
  end

  private

  def to_fnm(options)
    return File::FNM_DOTMATCH if options[:select_all_files]

    NO_OPTION
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
