# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Debugr::Engine do
  let(:script_path) { File.expand_path('tmp/script.rb', Dir.pwd) }
  let(:session) { OpenStruct.new(script: script_path, bp_manager: nil) }
  subject(:engine) { described_class.new(session) }

  describe '#should_pause?' do
    it 'returns true at a breakpoint' do
      bp_manager = Debugr::BreakpointManager.new
      session.bp_manager = bp_manager
      bp_manager.add('99', OpenStruct.new(path: script_path))

      expect(engine.send(:should_pause?, OpenStruct.new(event: :line, lineno: 99), script_path)).to be true
    end

    it 'returns true when mode is :step' do
      engine.step!
      expect(engine.send(:should_pause?, OpenStruct.new(event: :line, lineno: 99), script_path)).to be true
    end

    context 'when mode is :next' do
      before(:each) do
        engine.instance_variable_set(:@user_started, true) # prevents depth from resetting on tests
        engine.instance_variable_set(:@call_depth, 5)
        engine.next! # @next_target_depth == 5
      end

      it 'returns true when at the original call depth' do
        expect(engine.send(:should_pause?, OpenStruct.new(event: :line, lineno: 10), script_path)).to be true
      end

      it 'returns true when above the original call depth' do
        engine.send(:handle_event, build_tp(event: :return, path: script_path, lineno: 75)) # call_depth == 4
        engine.send(:handle_event, build_tp(event: :return, path: script_path, lineno: 28)) # call_depth == 3

        expect(engine.send(:should_pause?, OpenStruct.new(event: :line, lineno: 10), script_path)).to be true
      end

      it 'returns false when deeper than original call depth' do
        engine.send(:handle_event, build_tp(event: :call, path: script_path, lineno: 10)) # call_depth == 6

        expect(engine.send(:should_pause?, OpenStruct.new(event: :line, lineno: 11), script_path)).to be false
      end
    end

    it 'returns false when not at breakpoint AND mode is not :step or :next' do
      engine.continue! # sets mode to :running

      # Session.bp_manager is nil so there are no breakpoints

      expect(engine.send(:should_pause?, OpenStruct.new(event: :line, lineno: 99), script_path)).to be false
    end
  end

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
