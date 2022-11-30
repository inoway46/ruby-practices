# frozen_string_literal: true

module ListSegment
  module FileOption
    NO_FILE_OPTION = 0

    private

    def to_fnm
      @options.select_all_files? ? File::FNM_DOTMATCH : NO_FILE_OPTION
    end

    def sort_files(files)
      @options.reverse_sort? ? files.sort.reverse : files.sort
    end
  end
end
