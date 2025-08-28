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
def build_tp(path:, lineno:, event: :line, binding: nil)
  OpenStruct.new(path: path, lineno: lineno, event: event, binding: binding)
end
