# This Engine is the core of the debugger. It's responsibilities are to:
# 1. Enable a TracePoint for noteworthy events (:line, :call, :return, :raise)
# 2. Track call depth so `next` can be implemented
# 3. On each :line event, decide whether to pause when:
#       - a breakpoint matches
#       - or mode == :step
#       - or mode == :next and returned to or above the target depth
# 4. When pausing, run a REPL that uses tp.binding to inspect / eval

require_relative "breakpoints"
require_relative "repl"

module Debugr
  class Engine
    def initialize(session)
      @session = session              # Session object passed from Session.new
      @mode = :running                # mode can be :running, :paused, :step, :next
      @call_depth = 0                 # call depth counter
      @next_target_depth = nil        # used for `next` command (will skip over lines when this is > @call_depth)
      @current_tp = nil               # last TracePoint object seen
      @trace = nil                    # reference to TracePoint so it can be disabled later
    end

    def start
      @trace = TracePoint.new(:line, :call, :return) do |tp|                  # Set up TracePoint to listen for :line, :call and :return events
        case tp.event
        when :line
          file = File.expand_path(tp.path)
          if @session.breakpoints.match?(file, tp.lineno, tp.binding)         # Pause if a breakpoint is encountered
            pause(tp)
          elsif @mode == :step                                                # Pause if in step mode
            pause(tp)
          elsif @mode == :next
            if @next_target_depth && @call_depth <= @next_target_depth        # If in next mode, pause only after returned to the original call depth
              pause(tp)
            end
          end
        when :call
          @call_depth += 1
        when :return
          @call_depth -= 1
        end
      end

      # Script will run within enable block
      @trace.enable do
        yield                         
      end
    
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
  end
end
