# frozen_string_literal: true

COMMAND_ALIASES = {
  call_next: %w[n next],
  call_step: %w[s step],
  call_continue: %w[c continue],
  quit!: %w[q quit],
  safe_eval_and_print: %w[p eval],
  call_add_breakpoint: %w[b break],
  list_locals: %w[locals],
  show_backtrace: %w[where bt backtrace],
  list_breakpoints: %w[breaks breakpoints lb list],
  print_help: %w[help ?]
}.freeze

COMMANDS = COMMAND_ALIASES.flat_map do |method, keys|
  keys.map { |key| [key, method] }
end.to_h.freeze

HELP_COMMANDS = {
  '[n, next]' => 'step over (skip into deeper calls)',
  '[s, step]' => 'step in (pause at next line even inside calls)',
  '[c, continue]' => 'continue until next breakpoint or program ends',
  '[p <expr>]' => 'evaluate Ruby <expr> in current frame and print',
  '[eval <ruby>]' => 'alias for p',
  '[locals]' => 'show local variables in current frame',
  '[where, bt]' => 'display a short backtrace',
  '[b <file>:<line>]' => 'add breakpoint (if breakpoints manager implemented)',
  '[breaks, list]' => 'list breakpoints',
  '[q, quit]' => 'quit debugga and abort program',
  '[help, ?]' => 'show this helps'
}.freeze

COLORS = {
  'RED' => "\33[91m",
  'BLUE' => "\33[94m",
  'GREEN' => "\033[32m",
  'YELLOW' => "\033[93m",
  'PURPLE' => '\033[0;35m',
  'CYAN' => "\033[36m",
  'END' => "\033[0m"
}.freeze
