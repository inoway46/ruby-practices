# frozen_string_literal: true

Dir["#{File.dirname(__FILE__)}/ls_modules/*.rb"].sort.each { |file| require file }

opt = ListSegment::Option.new
ls = opt.options[:long_format] ? ListSegment::LongFormat.new(opt.options) : ListSegment::DefaultFormat.new(opt.options)
ls.output
