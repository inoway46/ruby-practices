# frozen_string_literal: true

require 'optparse'

module ListSegment
  class Option
    def initialize
      @options = {}
      OptionParser.new do |option|
        option.on('-a') { |v| @options[:select_all_files] = v }
        option.on('-l') { |v| @options[:long_format] = v }
        option.on('-r') { |v| @options[:reverse_sort] = v }
        option.parse!(ARGV)
      end
    end

    def select_all_files?
      @options[:select_all_files]
    end

    def reverse_sort?
      @options[:reverse_sort]
    end

    def long_format?
      @options[:long_format]
    end
  end
end
