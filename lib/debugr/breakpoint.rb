# frozen_string_literal: true

module Debugr
  # Class for creating and enabling/disabling breakpoints
  class Breakpoint
    attr_accessor :id, :file, :line, :binding, :enabled

    def initialize(id:, file:, line:, binding:)
      @id = id
      @file = file
      @line = line
      @binding = binding
      @enabled = true
    end

    def enable
      @enabled = true
    end

    def disable
      @enabled = false
    end
  end
end
