# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Debugr::Engine do
  let(:script_path) { File.expand_path('tmp/script.rb', Dir.pwd) }
  let(:script_dir) { File.dirname(script_path) }
  let(:session) { OpenStruct.new(script: script_path, bp_manager: nil) }
  let(:paused) { [] }

  subject(:engine) { described_class.new(session) }

  before(:each) do
    allow(engine).to receive(:pause) do |tp| # Spoof the :pause method to avoid opening the REPL
      paused << [tp.path, tp.lineno]
      engine.continue!
    end
  end

  context 'call/return depth tracking' do
    it 'increments on :call' do
      expect(engine.instance_variable_get(:@call_depth)).to eq(0)

      tp_call = build_tp(event: :call, path: script_path, lineno: 1)
      engine.send(:handle_event, tp_call)
      expect(engine.instance_variable_get(:@call_depth)).to eq(1)
    end

    it 'decrements on :return' do
      expect(engine.instance_variable_get(:@call_depth)).to eq(0)

      tp_return = build_tp(event: :return, path: script_path, lineno: 1)
      engine.send(:handle_event, tp_return)
      expect(engine.instance_variable_get(:@call_depth)).to eq(-1)
    end
  end

  context 'step mode behaviour' do
    before(:each) do
      engine.step!
    end

    it 'pauses on the next :line event' do
      tp_line = build_tp(event: :line, path: script_path, lineno: 23)
      engine.send(:handle_event, tp_line)

      expect(paused).to eq([[script_path, 23]])
    end
  end

  context 'next mode behaviour' do
    before(:each) do
      engine.next!
    end

    it 'skips pause while deeper than the original depth' do
      engine.send(:handle_event, build_tp(event: :call, path: script_path, lineno: 10))
      expect(engine.instance_variable_get(:@call_depth)).to eq(1)

      engine.send(:handle_event, build_tp(event: :line, path: script_path, lineno: 11))
      expect(paused).to be_empty
    end

    it 'pauses after returning to the original depth' do
      engine.send(:handle_event, build_tp(event: :call, path: script_path, lineno: 10))
      engine.send(:handle_event, build_tp(event: :line, path: script_path, lineno: 11))
      engine.send(:handle_event, build_tp(event: :return, path: script_path, lineno: 11))
      engine.send(:handle_event, build_tp(event: :line, path: script_path, lineno: 12))

      expect(paused).to_not be_empty
    end
  end

  context 'breakpoint behaviour' do
    before(:each) do
      @bp_manager = Debugr::BreakpointManager.new
      session.bp_manager = @bp_manager
      @bp_manager.add("#{script_path}:99", OpenStruct.new(path: script_path, binding: nil))
    end

    it 'pauses when a breakpoint matching file+line exists' do
      engine.send(:handle_event, build_tp(event: :line, path: script_path, lineno: 99))
      expect(paused).to_not be_empty
    end

    it 'does not pause when no matching breakpoint exists' do
      engine.send(:handle_event, build_tp(event: :line, path: script_path, lineno: 101))
      expect(paused).to be_empty
    end
  end
end
