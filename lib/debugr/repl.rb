require 'readline' rescue nil

module Debugr
  class REPL
    def initialize(engine, tp)
      @engine = engine
      @tp = tp
      @session = @engine.instance_variable_get(:session) rescue nil
    end

    def start
      file, lineno = @tp.path, @tp.lineno
      puts "\n[debugr] Paused at #{file}:#{lineno}"
      puts "Type 'help' for commands."

      loop do
        line = read_input("(debugr) ")
        break if line.nil? # End of file -> quit

        cmd, *rest = line.strip.split(' ', 2)
        arg = rest.first

        case cmd
        when 'n', 'next'
          @engine.next!
          return
        when 's', 'step'
          @engine.step!
          return
        when 'c', 'continue'
          @engine.continue!
          return
        when 'q', 'quit', 'exit'
          puts "Exiting debugger..."
          exit 0
        when 'p'
          if arg.nil?
            puts "Usage: p <expression>"
        when 'eval' # alias for p
          if arg.nil?
            puts "Usage: eval <ruby_code>"
          else
            safe_eval_and_print(arg)
          end
        when 'locals'
          list_locals
        when 'where', 'bt', 'backtrace'
          show_backtrace
        when 'b', 'break'
          # break usage: b filepath:linenumber  OR  b linenumber  (same file)
          add_breakpoint(arg)
        when 'breaks', 'breakpoints', 'lb', 'list'
          list_breakpoints
        when 'help', '?'
          print_help
        else
          if line.strip.empty?
            next
          else
            puts "Unknwon command: #{cmd.inspect}. Type 'help' for commands."
        end
      end
    end

    private

    def read_input
    end

    def safe_eval_and_print
    end

    def list_locals
    end

    def show_backtrace
    end

    def add_breakpoint
    end

    def print_help
    end
  end
end