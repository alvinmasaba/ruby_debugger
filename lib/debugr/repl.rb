# frozen_string_literal: true

begin
  require 'readline'
rescue StandardError
  nil
end

require 'constants'

module Debugr
  # The REPL launches the debugger in the command line.
  class REPL
    COMMANDS = COMMAND_ALIASES.flat_map do |method, keys|
      keys.map { |key| [key, method] }
    end.to_h.freeze

    def initialize(engine, tp)
      @engine = engine
      @tp = tp
      # @session = extract_session(engine)
      @session = extract_session(@engine)
      @bp_manager = @session&.breakpoints
    end

    def start
      print_debugger_header
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

    def print_debugger_header
      puts "\n[debugr] Paused at #{@tp.path}:#{@tp.lineno}"
      puts "Type 'help' for commands."
    end

    def main_debug_loop
      loop do
        line = read_input('(debugr) ')
        # End of file -> quit
        break if line.nil?

        next if handle_command_line(line)
      end
    end

    def handle_command_line(line)
      return true if line.strip.empty?

      cmd, arg = parse_command_line(line)

      if COMMANDS.key?(cmd)
        result = arg.nil? ? send(COMMANDS[cmd]) : send(COMMANDS[cmd], arg)
        false if result == :break_loop
      else
        puts "Unknwon command: #{cmd.inspect}. Type 'help' for commands."
      end
    end

    def parse_command_line(line)
      cmd, *rest = line.strip.split(' ', 2)
      [cmd, rest.first]
    end

    # Read input using Readline if it's available, otherwise fall back to $stdout.gets
    def read_input(prompt)
      if readline_available?
        Readline.readline(prompt, true)
      else
        print prompt
        $stdout.gets&.chomp
      end
    end

    def readline_available?
      defined?(Readline) && Readline.respond_to?(:readline)
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

    def determine_file_and_line(arg)
      if arg.include?(':')
        file_str, line_str = arg.split(':', 2)
        [File.expand_path(file_str), line_str.to_i]
      else
        # when given just number, assume current file
        [@tp.path, arg.to_i]
      end
    end

    def list_breakpoints
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

    def print_help
      body = HELP_COMMANDS.map do |c, d|
        "    #{c.ljust(18)} - #{d}"
      end.join("\n")

      puts <<~HELP
        Commands:
        #{body}
      HELP
    end
  end
end
