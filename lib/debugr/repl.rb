# frozen_string_literal: true

require 'constants'
require 'cmd_helpers'

module Debugr
  # The REPL launches the debugger in the command line.
  class REPL
    def initialize(engine, tp)
      @engine = engine
      @tp = tp
      # @session = extract_session(engine)
      @session = extract_session(@engine)
      @bp_manager = @session&.breakpoints
    end

    def start
      print_debugger_header(@tp.path, @tp.lineno)
      main_debug_loop
    end

    private

    def call_next
      @engine.next!
    end

    def call_step
      @engine.step!
    end

    def call_continue
      @engine.continue!
    end

    def quit!
      puts 'Exiting debugger...'
      exit 0
    end

    def extract_session(engine)
      engine.instance_variable_get(:@session)
    rescue StandardError
      nil
    end

    def main_debug_loop
      loop do
        line = read_input('(debugr) ')
        # End of file -> quit
        break if line.nil?

        next if handle_command_line(line)
      end
    end

    # Evaluate code string in the paused frame binding and print the result
    def safe_eval_and_print(code_to_eval)
      b = @tp.binding
      begin
        result = b.eval(code_to_eval)
        puts "=> #{result.inspect}"
      rescue StandardError => e
        puts "Eval error: #{e.class}: #{e.message}"
      end
    end

    # Print local variables and their values in frame
    def list_locals
      b = @tp.binding
      names = b.local_variables

      return puts '(no local variables)' if names.empty?

      names.each do |name|
        value = b.eval(name.to_s)
        puts "#{name} = #{value.inspect}"
      rescue StandardError => e
        puts "#{name} = <error: #{e.class}>"
      end
    end

    # Display a simple backtrace relevant to paused input.
    # caller_locations is called to keep it simple and reliable
    def show_backtrace
      puts 'Backtrace (top 10):'
      caller_locations(0, 10).each_with_index do |loc, i|
        puts "  #{i}: #{loc.path}:#{loc.lineno} in #{loc.label}"
      end
    end

    # Breakpoint helpers - warn if session or breakpoints aren't implemented
    def call_add_breakpoint(arg)
      return puts 'Usage: b file.rb:line   or  b line (uses current file)' if arg.nil? || arg.strip.empty?

      return puts 'Breakpoints manager not available (not implemented yet).' unless @bp_manager

      @bp_manager.add(arg, @tp)
    end

    def call_list_breakpoints
      return puts 'Breakpoints manager not available (not implemented yet).' unless @bp_manager

      bps = bp_manager.list
      if bps.empty?
        puts '(no breakpoints)'
      else
        bps.each do |bp|
          puts "#{bp.id}: #{bp.file}:#{bp.line} #{bp.enabled ? '' : '(disabled)'}"
        end
      end
    end
  end
end
