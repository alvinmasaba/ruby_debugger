require_relative 'breakpoint'

module Debugr
  class BreakpointManager
    def initialize
      @bps = []
      @next_id = 1
    end
    
    def add(file, line)
      id = @next_id
      @next_id += 1
      bp = Breakpoint.new(id: id, file: File.expand_path(file), line: line)
      @bps << bp
      @next_id
    end
    
    def list
      @bps
    end
    
    def match?(file, lineno, binding)
      @bps.any?{ |b| b[:enabled] && b[:file] == File.expand_path(file) && b[:line] == lineno }
    end
  end  
end