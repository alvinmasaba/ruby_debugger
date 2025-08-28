# frozen_string_literal: true

require 'tmpdir'
require 'ostruct'
require 'fileutils'

def write_temp_script(contents)
  dir = Dir.mktmpdir('debugr_spec')
  path = File.join(dir, "test_script_#{Time.now.to_i}_#{rand(9999)}.rb")
  File.write(path, contents)
  path
end

def find_lineno(path, fragment)
  File.readlines(path).find_index { |ln| ln.include?(fragment) } + 1
end

# Fake TracePoint-like double for unit tests
def fake_tp(path:, lineno:, event: :line, binding: nil)
  OpenStruct.new(path: path, lineno: lineno, event: event, binding: binding)
end

# Run engine.start with a session, but intercept pauses.
# paused_events will be appended [path, lineno, tp] for each call to pause.
def capture_pauses(session, engine, &block)
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
