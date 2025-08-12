module Debugr
  class Engine
    def initialize(session)
      @session = session
    end

    # Temporary start stub: will be replaced with real TracePoint code.
    def start
      puts "Engine.start called. (TracePoint is not implemented yet.)"
      yield
    end
  end
end