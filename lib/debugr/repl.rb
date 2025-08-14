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
          end
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
    end

    private

    # Read input using Readline if it's available, otherwise fall back to STDIN.gets
    def read_input(prompt)
      if defined?(Readline) && Readline.respond_to?(:readline)
        input = Readline.readline(prompt, true)
        return nil if input.nil?
        input
      else
        print prompt
        STDIN.gets&.chomp
      end
    end

    # Evaluate code string in the paused frame binding and print the result
    def safe_eval_and_print
      b = @tp.binding
      begin
        result = b.eval(code)
        puts "=> #{result.inspect}"
      rescue Exception => e
        puts "Eval error: #{e.class}: #{e.message}"
      end      
    end

    # Print local variables and their values in frame
    def list_locals
      b = @tp.binding
      names = b.local_variables
      if names.empty?
        puts "(no local variables)"
        return
      end
      names.each do |name|
        begin
          value = b.eval(name.to_s)
          puts "#{name} = #{value.inspect}"
        rescue Exception => e
          puts "#{name} = <error: #{e.class}>"
        end
      end
    end

    # Display a simple backtrace relevant to paused input.
    # caller_locations is called to keep it simple and reliable
    def show_backtrace
      puts "Backtrace (top 10):"
      caller_locations(0, 10).each_with_index do |loc, i|
        puts "  #{i}: #{loc.path}:#{loc.lineno} in #{loc.label}"
      end
    end

    # Breakpoitn helpers - warn if session or breakpoints aren't implemented
    def add_breakpoint
      if arg.nil? || arg.strip.empty?
        puts "Usage: b file.rb:line   or  b line (uses current file)"
        return
      end

      bp_manager = @session&.breakpoints
      unless bp_manager
        puts "Breakpoints manager not available (not implemented yet)."
        return
      end

      if arg.include?(':')
        file_str, line_str = arg.split(':', 2)
        file = File.expand_path(file_str)
        line = line_str.to_i
      else
        # when given just number, assume current file
        file = @tp.path
        line = arg.to_i
      end

      id = bp_manager.add(file, line)
      puts "Breakpoint ##{id} set at #{file}:#{line}"
    end
    
    def list_breakpoints
      bp_manager = @session&.breakpoints
      unless bp_manager
        puts "Breakpoints manager not available (not implemented yet)"
        return
      end
      bps = bp_manager.list
      if bps.empty?
        puts "(no breakpoints)"
      else
        bps.each do |bp|
          puts "#{bp.id}: #{bp.file}:#{bp.line} #{bp.enabled ? '' : '(disabled)'}"
        end
      end
    end

    def print_help
      puts <<~HELP
        Commands:
          n, next           - step over (skip into deeper calls)
          s, step           - step in (pause at next line even inside calls)
          c, continue       - continue until next breakpoint or program ends
          p <expr>          - evaluate Ruby <expr> in current frame and print
          eval <ruby>       - alias for p
          locals            - show local variables in current frame
          where, bt         - display a short backtrace
          b <file>:<line>   - add breakpoint (if breakpoints manager implemented)
          breaks, list      - list breakpoints
          q, quit           - quit debugger and abort program
          help, ?           - show this helps
      HELP
    end
  end
end