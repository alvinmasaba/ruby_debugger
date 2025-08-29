# frozen_string_literal: true

# Module to ship colorize method.
module TerminalColors
  CODES = {
    red: 31,
    green: 32,
    yellow: 33,
    blue: 34,
    pink: 35,
    cyan: 36,
    white: 37
  }.freeze

  # Adds color to terminal text
  def self.colorize(text, color)
    code = color.is_a?(Integer) ? color : CODES.fetch(color.to_sym)
    "\e[#{code}m#{text}\e[0m"
  end
end
