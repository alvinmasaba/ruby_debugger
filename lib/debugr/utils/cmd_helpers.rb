# frozen_string_literal: true

begin
  require 'readline'
rescue StandardError
  nil
end

require_relative 'constants'
require_relative 'terminal_colors'

# CMD Helpers

def parse_command_line(line)
  cmd, *rest = line.strip.split(' ', 2)
  [cmd, rest.first]
end

def print_debugger_header(path, lineno)
  puts "\n[debugga] Paused at #{path}:#{lineno}"
  puts "Type 'help' for commands."
end

def print_help(_arg = nil)
  body = HELP_COMMANDS.map do |c, d|
    "    #{c.ljust(18)} - #{d}"
  end.join("\n")

  puts <<~HELP
    Commands:
    #{body}
  HELP
end

# Read input using Readline if it's available, otherwise fall back to $stdout.gets
def read_input(prompt)
  if readline_available?
    line = Readline.readline(prompt, true)&.downcase
  else
    print prompt
    line = $stdout.gets
  end

  line = line&.chomp
  line&.downcase
end

def readline_available?
  defined?(Readline) && Readline.respond_to?(:readline)
end

def color(text, color_name)
  TerminalColors.colorize(text, color_name)
end

def print_banner
  font = "
          __________
         /  ____   /________________          ________________________
        /  /   /  /  _____/  ___   /         /  _________/  _________/
       /  /   /  /  /____/  /_ /  /__    ___/  /  ______/  /  ________________
      /  /   /  /  _____/  ___   /  /   /  /  /  /__   /  /  /__   /  ____    |
     /  /___/  /  /____/  /_ /  /  /___/  /  /_____/  /  /_____/  /  /___/ |  |
    /_________/_______/________/_________/___________/___________/________/|__| "

  puts color(font, :green)
end
