# frozen_string_literal: true

# Run engine.start with a session, but intercept pauses.
# paused_events will be appended [path, lineno, tp] for each call to pause.
def capture_pauses(engine, &block)
  paused = []
  # override pause for this engine instance
  engine.define_singleton_method(:pause) do |tp|
    paused << [tp.path, tp.lineno, tp]
    # simulate user choosing to continue so the scrip doesn't block
    continue!
  end

  engine.start(&block)
  paused
end
