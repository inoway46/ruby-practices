# frozen_string_literal: true

require_relative 'ls_modules/option'
require_relative 'ls_modules/default_format'
require_relative 'ls_modules/long_format'

opt = ListSegment::Option.new
ls = opt.options[:long_format] ? ListSegment::LongFormat.new(opt.options) : ListSegment::DefaultFormat.new(opt.options)
ls.output
