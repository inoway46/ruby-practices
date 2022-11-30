# frozen_string_literal: true

require_relative 'ls_modules/option'
require_relative 'ls_modules/default_format'
require_relative 'ls_modules/long_format'

opt = ListSegment::Option.new
ls = opt.long_format? ? ListSegment::LongFormat.new(opt) : ListSegment::DefaultFormat.new(opt)
ls.output
