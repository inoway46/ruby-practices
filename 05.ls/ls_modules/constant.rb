# frozen_string_literal: true

module ListSegment
  module Constant
    NO_FILE_OPTION = 0
  end

  module LongFormatConstant
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
  end
end
