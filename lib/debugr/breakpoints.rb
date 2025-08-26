# frozen_string_literal: true

require_relative 'breakpoint'

module Debugr
  class BreakpointManager
    def initialize
      @bps = []
      @next_id = 1
    end

    def add(arg, tp)
      binding = tp.binding
      file, line = determine_file_and_line(arg, tp)
      id = @next_id
      @next_id += 1
      bp = Breakpoint.new(id: id, file: File.expand_path(file), line: line, binding: binding)
      @bps << bp

      puts "Breakpoint ##{id} set at #{file}:#{line}"
    end

    def list
      @bps
    end

    def match?(file, lineno, binding)
      @bps.any? do |b|
        b.enabled && b.file == File.expand_path(file) && b.line == lineno && b.binding == binding
      end
    end

    private

    def determine_file_and_line(arg, tp)
      if arg.include?(':')
        file_str, line_str = arg.split(':', 2)
        [File.expand_path(file_str), line_str.to_i]
      else
        # when given just number, assume current file
        [tp.path, arg.to_i]
      end
    end
  end
end
