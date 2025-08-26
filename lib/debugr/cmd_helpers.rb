# frozen_string_literal: true

begin
  require 'readline'
rescue StandardError
  nil
end

require 'constants'

# CMD Helpers

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

def print_debugger_header(path, lineno)
  puts "\n[debugr] Paused at #{path}:#{lineno}"
  puts "Type 'help' for commands."
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

# Readline Helpers

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
