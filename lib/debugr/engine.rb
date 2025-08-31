# frozen_string_literal: true

require_relative 'breakpoints'
require_relative 'repl'
require_relative 'utils/file_helpers'
require_relative 'utils/cmd_helpers'
require_relative 'utils/engine_helpers'

module Debugr
  # The Engine is responsible for managing execution flow. It uses TracePoint to intercept events like line execution,
  # method calls,and returns. It maintains the debugger's state (e.g., :running, :step, :next) and decides when to
  # pause execution and launch the REPL.
  class Engine
    attr_reader :session

    def initialize(session)
      @session = session              # Session object passed from Session.new
      @mode = :running                # :running, :paused, :step, :next
      @call_depth = 0                 # call depth counter
      @next_target_depth = nil        # used for `next` command (will skip over lines when this is > @call_depth)
      @current_tp = nil               # last TracePoint object seen
      @trace = nil                    # reference to TracePoint so it can be disabled later
      @debugger_dir = File.expand_path(__dir__) # Directory where Debugga lives 'lib/debugr'
    end

    def start(&block)
      print_banner
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

    private

    def pause(tp)
      @mode = :paused
      @current_tp = tp
      repl = REPL.new(self, tp)     # instantiate the REPL with the engine and current TracePoint
      repl.start                    # when the REPL returns, the user has chosen step/next/continue/quit
    end

    def handle_event(tp)
      user_started?
      file = get_abs_path(tp.path)

      case tp.event
      when :call
        @call_depth += 1
      when :return
        @call_depth -= 1
      when :line
        pause(tp) if should_pause?(tp, file)
      end
    end

    def user_started?
      return if @user_started

      @user_started = true
      @call_depth = 0
    end

    def should_pause?(tp, file)
      @bp_manager = @session.bp_manager

      # Pause at each breakpoint/after each step
      if @bp_manager&.match?(file, tp.lineno, tp.binding) || @mode == :step
        return true
      elsif @mode == :next
        # ON `next`, pause only after returned to or above the original call depth
        return @next_target_depth && @call_depth <= @next_target_depth
      end

      false
    end

    def should_process_path?(tp)
      path = tp.path
      return false if empty_or_internal?(path)

      # Get the absolute path
      abs_path = get_abs_path(path)

      # Exclude frames from the debugger's own files
      return false if within_debugger_dir(@debugger_dir, abs_path)

      # Compute allowed user dir from sessions.script
      target_script, target_dir = target_dir_and_script(@session)

      # If no target directory is set, assume all paths are valid.
      return true unless target_dir && !target_dir.empty?

      # Check if the path is the main script or within the script's directory.
      script_or_within_script_dir?(abs_path, target_script, target_dir)
    end

    # def current_binding
    #   @current_tp&.binding
    # end

    # def current_location
    #   [@current_tp&.path, @current_tp&.lineno]
    # end
  end
end
