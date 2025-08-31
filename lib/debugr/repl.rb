# frozen_string_literal: true

require_relative 'utils/cmd_helpers'
require_relative 'utils/constants'
require_relative 'utils/repl_commands'

module Debugr
  # The REPL launches the debugger in the command line.
  class REPL
    def initialize(engine, tp)
      @engine = engine
      @tp = tp
      @session = extract_session
      @bp_manager = @session&.bp_manager
      @cmd_obj = Debugr::ReplCommands.new(@engine, @tp, @bp_manager)
    end

    def start
      print_debugger_header(@tp.path, @tp.lineno)
      main_debug_loop
    end

    private

    def extract_session
      @engine.instance_variable_get(:@session)
    rescue StandardError
      nil
    end

    def main_debug_loop
      loop do
        line = read_input('(debugga) ')
        # End of file -> quit
        break if line.nil?

        break if handle_command(line) == :break_loop
      end
    end

    def handle_command(line)
      return if line.strip.empty?

      cmd, arg = parse_command_line(line)
      method_name = COMMANDS[cmd]

      if method_name&.is_a?(Symbol) && @cmd_obj.respond_to?(method_name, true)
        @cmd_obj.public_send(method_name, arg)
      else
        puts "Unknown command: #{cmd.inspect}. Type 'help' for commands."
      end
    end
  end
end
