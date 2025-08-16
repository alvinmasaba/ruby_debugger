# frozen_string_literal: true

require_relative 'breakpoint'

module Debugr
  class BreakpointManager
    def initialize
      @bps = []
      @next_id = 1
    end

    def add(file, line, binding)
      id = @next_id
      @next_id += 1
      bp = Breakpoint.new(id: id, file: File.expand_path(file), line: line, binding: binding)
      @bps << bp
      id
    end

    def list
      @bps
    end

    def match?(file, lineno, binding)
      @bps.any? do |b|
        b.enabled && b.file == File.expand_path(file) && b.line == lineno && b.binding == binding
      end
    end
  end
end
