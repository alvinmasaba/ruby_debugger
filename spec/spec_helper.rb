# frozen_string_literal: true

require 'rspec'
require 'tmpdir'
require 'support/engine_helpers'

# Load library
$LOAD_PATH.unshift(File.expand_path('../lib', __dir__))

require 'debugr/session'
require 'debugr/engine'
require 'debugr/breakpoint'
require 'debugr/breakpoints'
require 'debugr/repl'

RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.default_formatter = 'doc' # if config.files_to_run.one? # show full diff for failures
end
