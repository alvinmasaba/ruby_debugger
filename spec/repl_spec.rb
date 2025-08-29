# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Debugr::REPL do
  let(:engine) { double('engine') }
  let(:tp) { double('tp', path: 'fake/file.rb', lineno: 1) }
  subject(:repl) { described_class.new(engine, tp) }

  before do
    allow(repl).to receive(:print_debugger_header)
  end

  context 'step' do
    before(:each) do
      expect(engine).to receive(:step!)
    end

    it "calls engine.step! for 's'" do
      expect(repl.send(:handle_command, 's')).to eq(:break_loop)
    end

    it "calls engine.step! for 'step'" do
      expect(repl.send(:handle_command, 'step')).to eq(:break_loop)
    end
  end

  context 'next' do
    before(:each) do
      expect(engine).to receive(:next!)
    end

    it "calls engine.next! for 'n'" do
      expect(repl.send(:handle_command, 'n')).to eq(:break_loop)
    end

    it "calls engine.next! for 'next'" do
      expect(repl.send(:handle_command, 'next')).to eq(:break_loop)
    end
  end

  context 'continue' do
    before(:each) do
      expect(engine).to receive(:continue!)
    end

    it "calls engine.continue! for 'c'" do
      expect(repl.send(:handle_command, 'c')).to eq(:break_loop)
    end

    it "calls engine.continue! for 'continue'" do
      expect(repl.send(:handle_command, 'continue')).to eq(:break_loop)
    end
  end

  context 'eval' do
    it 'evaluates expressions in the paused frame' do
      fake_binding = double('binding')
      allow(tp).to receive(:binding).and_return(fake_binding)
      allow(fake_binding).to receive(:eval).with('1+1').and_return(2)

      repl.instance_variable_set(:@tp, tp)
      expect { repl.send(:safe_eval_and_print, '1+1') }.to output(/=> 2/).to_stdout
    end
  end
end
