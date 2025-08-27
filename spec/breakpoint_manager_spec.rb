# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Debugr::BreakpointManager do
  subject(:manager) { described_class.new }

  let(:file) { File.expand_path('some_file.rb', Dir.pwd) }
  let(:tp_double) do
    instance_double(TracePoint, binding: binding, path: file)
  end

  describe '#add' do
    it 'creates a new breakpoint' do
      manager.add('10', tp_double)
      bp = manager.list.first

      expect(bp).to be_a(Debugr::Breakpoint)
    end

    it 'adds a new breakpoint to the list of breakpoints' do
      expect { manager.add('10', tp_double) }.to change { manager.list.size }.by(1)
    end

    it 'assigns a unique, incrementing id' do
      manager.add('10', tp_double)
      manager.add('11', tp_double)

      first_bp = manager.list.first
      last_bp = manager.list.last

      expect(first_bp.id).to eq(1)
      expect(last_bp.id).to eq(2)
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

  describe '#match' do
  end
end
