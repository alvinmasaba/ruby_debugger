# frozen_string_literal: true

COMMAND_ALIASES = {
  call_next: %w[n next],
  call_step: %w[s step],
  call_continue: %w[c continue],
  call_quit: %w[q quit],
  safe_eval_and_print: %w[p eval],
  call_add_breakpoint: %w[b break],
  list_locals: %w[locals],
  show_backtrace: %w[where bt backtrace],
  list_breakpoints: %w[breaks breakpoints lb list],
  print_help: %w[help ?]
}.freeze

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
  '[q, quit]' => 'quit debugger and abort program',
  '[help, ?]' => 'show this helps'
}.freeze
