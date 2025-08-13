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
      # mode can be :running, :paused, :step, :next
      @mode = :running
      @call_depth = 0                 # call depth counter
      @next_target_depth = nil        # used for `next` command
      @current_tp = nil               # last TracePoint object seen
      @trace = nil                    # reference to TracePoint so it can be disabled later
    end

    def start
      # Set up TracePoint to listen for :line, :call and :return events
      @trace = TracePoint.new(:line, :call, :return) do |tp|
        case tp.event
        when :line
          file = File.expand_path(tp.path)
          # Pause if we encounter a breakpoint
          if @session.breakpoints.match?(file, tp.lineno, tp.binding)
            pause(tp)
          # Pause if we're in step mode
          elsif @mode == :step 
            pause(tp)
          # If we're in next mode, pause only after we've returned to the original call depth
          elsif @mode == :next
            if @next_target_depth && @call_depth <= @next_target_depth
              pause(tp)
            end
          end
        when :call
          # increment call depth
          @call_depth += 1
        when :return
          # decrement call depth
          @call_depth -= 1
        end
      end

      @trace.enable do
        yield
      end

    ensure
      # disable the trace to prevent unintended leaking elsewhere
      @trace&.disable
    end

    private

    def pause(tp)
      @mode = :paused
      puts "Paused at #{tp.path}:#{tp.lineno}"
      puts "Press ENTER to continue..."
      gets
      @mode = :running
    end
  end
end
