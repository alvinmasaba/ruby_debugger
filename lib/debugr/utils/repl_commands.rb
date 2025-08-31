# frozen_string_literal: true

module Debugr
  # Contains all the commands to be called by the REPL
  class ReplCommands
    def initialize(engine, tp, bp_manager)
      @engine = engine
      @tp = tp
      @bp_manager = bp_manager
    end

    def quit!(_arg = nil)
      puts 'Exiting debugga...'
      exit 0
    end

    def call_next(_arg = nil)
      @engine.next!
      :break_loop
    end

    def call_step(_arg = nil)
      @engine.step!
      :break_loop
    end

    def call_continue(_arg = nil)
      @engine.continue!
      :break_loop
    end

    # Breakpoint helpers - warn if session or breakpoints aren't implemented
    def call_add_breakpoint(arg)
      return puts 'Usage: b file.rb:line   or  b line (uses current file)' if arg.nil? || arg.strip.empty?

      return puts 'Breakpoints manager not available (not implemented yet).' unless @bp_manager

      @bp_manager.add(arg, @tp)
      bp = @bp_manager.list.last

      puts "Breakpoint ##{bp.id} set at #{bp.file}:#{bp.line}"
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
    def list_locals(_arg = nil)
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

    def list_breakpoints(_arg = nil)
      return puts 'Breakpoints manager not available (not implemented yet).' unless @bp_manager

      bps = @bp_manager.list
      if bps.empty?
        puts '(no breakpoints)'
      else
        bps.each do |bp|
          puts "#{bp.id}: #{bp.file}:#{bp.line} #{bp.enabled ? '' : '(disabled)'}"
        end
      end
    end

    # Display a simple backtrace relevant to paused input.
    # caller_locations is called to keep it simple and reliable
    def show_backtrace(_arg = nil)
      puts 'Program backtrace (top 10):'
      begin
        b = @tp.binding
        b.eval('caller_locations(0, 10)').each_with_index do |loc, i|
          puts "  #{i}: #{loc.path}:#{loc.lineno} in #{loc.label}"
        end
      rescue StandardError => e
        puts "Could not fetch program backtrace: #{e.class}: #{e.message}"
      end
    end
  end
end
