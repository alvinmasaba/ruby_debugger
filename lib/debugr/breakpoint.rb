module Debugr
  class Breakpoint
    attr_accessor :id, :file, :line, :enabled

    def initialize(id:, file:, line:)
      @id = id
      @file = file
      @line = line
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