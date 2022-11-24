# frozen_string_literal: true

require 'optparse'

module ListSegment
  class Option
    attr_reader :options

    def initialize
      @options = {}
      OptionParser.new do |option|
        option.on('-a') { |v| @options[:select_all_files] = v }
        option.on('-l') { |v| @options[:long_format] = v }
        option.on('-r') { |v| @options[:reverse_sort] = v }
        option.parse!(ARGV)
      end
    end
  end
end
