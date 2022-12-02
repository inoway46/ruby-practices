# frozen_string_literal: true

require_relative 'file_option'

module ListSegment
  class DefaultFormat
    include FileOption

    def initialize(options = {}, column_num = 3)
      @options = options
      @column_num = column_num
      @files = sort_files(Dir.glob('*', to_fnm))
    end

    def output
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

    private

    def mod
      @files.size % @column_num
    end

    def calc_row_num
      (@files.size / @column_num) + mod
    end

    def count_max_file_name_str(add_space = 2)
      @files.map(&:length).max + add_space
    end
  end
end
