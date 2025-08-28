# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Debugr::BreakpointManager do
  subject(:manager) { described_class.new }

  let(:file) { File.expand_path('some_file.rb', Dir.pwd) }
  let(:tp_double) do
    instance_double(TracePoint, binding: binding, path: file)
  end

  describe '#add' do
    it 'creates and returns a breakpoint' do
      bp = manager.add('10', tp_double)
      expect(bp).to be_a(Debugr::Breakpoint)
    end

    it 'adds a new breakpoint to the list of breakpoints' do
      expect { manager.add('10', tp_double) }.to change { manager.list.size }.by(1)
    end

    it 'assigns a unique, incrementing id' do
      first_bp = manager.add('10', tp_double)
      last_bp = manager.add('11', tp_double)

      expect(first_bp.id).to eq(1)
      expect(last_bp.id).to eq(2)
    end

    it 'adds a breakpoint using numeric arg and tracepoint' do
      bp = manager.add('10', tp_double)

      expect(bp.file).to eq(file)
      expect(bp.line).to eq(10)
    end

    it 'adds a breakpoint using file:line arg and tracepoint' do
      bp = manager.add("#{file}:20", tp_double)

      expect(bp.file).to eq(file)
      expect(bp.line).to eq(20)
    end
  end

  describe '#list' do
    it 'returns a list of breakpoints' do
      manager.add('10', tp_double)
      manager.add('11', tp_double)
      manager.add('12', tp_double)

      breakpoints = manager.list

      breakpoints.each do |bp|
        expect(bp).to be_a(Debugr::Breakpoint)
      end
    end
  end

  describe '#match?' do
    it 'matches an enabled breakpoint by file and line' do
      manager.add("#{file}:30", tp_double)

      expect(manager.match?(file, 30, tp_double.binding)).to be true
      expect(manager.match?(file, 31, tp_double.binding)).to be false
    end

    it 'does not match disabled breakpoints' do
      bp = manager.add("#{file}:30", tp_double)
      bp.disable

      expect(manager.match?(file, 30, tp_double.binding)).to_not be true
    end
  end
end
