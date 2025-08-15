# frozen_string_literal: true

# This is the top level object that carries a shared state for a debugging run.
# Knows:
#   1. Which script will be debugged (@script)
#   2. Command line args to pass to that script (@script_args)
#   3. An Engine instance that wires TracePoint and controls execution

# Session#run method sets up the environment (e.g. ARGV) and calls engine.start { load script } so that TracePoint hooks
# are active while the target script runs.

require_relative 'engine'
require_relative 'breakpoints'

module Debugr
  class Session
    attr_reader :script, :script_args, :breakpoints, :engine

    # Initialize the session with the target script path and any args for that script.
    def initialize(script, args = [])
      @script = File.expand_path(script)
      @script_args = args.dup
      @script_dir = File.dirname(@script) # Will be useful for ignoring internal calls/frames in call depth

      # BreakpointManager stores and matches breakpoints
      @breakpoints = BreakpointManager.new

      # The Engine is the component that wraps TracePoint. 'self' is passed so that the engine can consult breakpoints
      # and other session state.
      @engine = Engine.new(self)
    end

    # Note that `engine.start` should yield to a block which loads / excecutes the target script. That way the
    # TracePoint is active during the script execution. The ARGV is set so that the debugged script sees the
    # expected command-line args.
    def run
      # Ensures the debugged script sees the arguments we want it to see
      ARGV.replace(@script_args)

      # Engine.start is expected to enable TracePoint and then yield to the block where the target script is loaded.
      # The engine will only disable TracePoint after the block finishes (exit script) or when an error occurs.
      @engine.start do
        # loading script runs it in the current process. Since the engine enabled TracePoint before yielding here, our
        # TracePoint callback will receive events as the script runs.
        load @script
      end
    end
  end
end
