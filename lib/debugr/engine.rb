# frozen_string_literal: true

# This Engine is the core of the debugger. It's responsibilities are to:
#   1. Enable a TracePoint for noteworthy events (:line, :call, :return etc...)
#   2. Track call depth so `next` can be implemented
#   3. On each :line event pause when:
#       - a breakpoint matches
#       - at each step
#       - on next when returned to or above the target depth
#   4. On pause, run a REPL that uses tp.binding to inspect / eval

require_relative 'breakpoints'
require_relative 'repl'

module Debugr
  class Engine
    attr_reader :session

    def initialize(session)
      @session = session              # Session object passed from Session.new
      @mode = :running                # :running, :paused, :step, :next
      @call_depth = 0                 # call depth counter
      @next_target_depth = nil        # used for `next` command (will skip over lines when this is > @call_depth)
      @current_tp = nil               # last TracePoint object seen
      @trace = nil                    # reference to TracePoint so it can be disabled later
    end

    def start(&block)
      # Create a tracepoint and store in instance variable (will listen for :line, :call, :return events)
      @trace = TracePoint.new(:line, :call, :return) do |tp|
        # Skip entirely if path is nil or internal frame or if it's not part of target code.
        next unless should_process_path?(tp)

        handle_event(tp)
      end

      # Script will run within enable block
      @trace.enable(&block)

    # After debug, disable the trace to prevent unintended leakage
    ensure
      @trace&.disable
    end

    # REPL helpers

    def step!
      @mode = :step
      @next_target_depth = nil
    end

    def next!
      @mode = :next
      @next_target_depth = @call_depth
    end

    def continue!
      @mode = :running
      @next_target_depth = nil
    end

    # Additional helpers

    def current_binding
      @current_tp&.binding
    end

    def current_location
      [@current_tp&.path, @current_tp&.lineno]
    end

    private

    def pause(tp)
      @mode = :paused
      @current_tp = tp
      repl = REPL.new(self, tp)     # instantiate the REPL with the engine and current TracePoint
      repl.start                    # when the REPL returns, the user has chosen step/next/continue/quit
    end

    def handle_event(tp)
      abs = get_abs_path(tp.path)
      case tp.event
      when :call
        @call_depth += 1
      when :return
        @call_depth -= 1
      when :line
        pause(tp) if should_pause?(tp, abs)
      end
    end

    def get_abs_path(path)
      File.expand_path(path)
    rescue StandardError
      path
    end

    def should_pause?(tp, abs)
      file = abs
      # Pause if a breakpoint is encountered
      @bp_manager = @session.breakpoints
      if @bp_manager&.match?(file, tp.lineno, tp.binding)
        return true
      # Pause after every step
      elsif @mode == :step
        return true
      elsif @mode == :next
        # Pause only after returned to or above the original call depth
        return @next_target_depth && @call_depth <= @next_target_depth
      end

      false
    end

    def should_process_path?(tp)
      path = tp.path
      return false if path.nil? || path.start_with?('<internal:')

      # Get the absolute path. Handle potential errors gracefully.
      abs_path = get_abs_path(path)

      # Cache the target directory to avoid repeated lookups.
      @target_dir ||= @session.respond_to?(:script_dir) ? @session.script_dir : @session.instance_variable_get(:@script_dir)

      # If no target directory is set, assume all paths are valid.
      return true unless @target_dir

      # Check if the path is the main script or within the script's directory.
      abs_path == @session.script || abs_path.start_with?(@target_dir)
    end
  end
end
