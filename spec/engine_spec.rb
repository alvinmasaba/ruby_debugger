# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Debugr::Engine do
  let(:script_path) { File.expand_path('tmp/script.rb', Dir.pwd) }
  let(:session) do
    # minimal session double exposing script and script_dir and bp_manager
    OpenStruct.new(script: script_path, bp_manager: nil)
  end
  subject(:engine) { described_class.new(session) }

  describe '#should_process_path?' do
    it 'rejects nil paths' do
      expect(engine.send(:should_process_path?, OpenStruct.new(path: nil))).to be false
    end

    it 'rejects internal paths' do
      expect(engine.send(:should_process_path?, OpenStruct.new(path: '<internal:trace_point>'))).to be false
    end

    it 'rejects debugger files under lib/debugr' do
      tp = OpenStruct.new(path: File.join(engine.instance_variable_get(:@debugger_dir), 'engine.rb'))
      expect(engine.send(:should_process_path?, tp)).to be false
    end

    it 'accepts paths inside the target dir' do
      tp = OpenStruct.new(path: File.join(File.dirname(script_path), 'lib', 'something.rb'))
      expect(engine.send(:should_process_path?, tp)).to be true
    end

    it 'accepts the path of the script itself' do
      tp = OpenStruct.new(path: script_path)
      expect(engine.send(:should_process_path?, tp)).to be true
    end
  end
end
