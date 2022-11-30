# frozen_string_literal: true

module ListSegment
  class DefaultFormat
    NO_FILE_OPTION = 0

    def initialize(options = {}, column_num = 3)
      @options = options
      @column_num = column_num
      @files = sort_files(Dir.glob('*', to_fnm))
      @stats = to_stats(@files) if options[:long_format]
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
  end
end
