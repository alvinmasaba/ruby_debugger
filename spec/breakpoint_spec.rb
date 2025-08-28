# frozen_string_literal: true

require_relative 'spec_helper'

RSpec.describe Debugr::Breakpoint do
  let(:file) { File.expand_path('some_file.rb', Dir.pwd) }
  let(:tp_double) do
    instance_double(TracePoint, binding: binding, path: file)
  end

  subject(:breakpoint) { described_class.new(id: 1, file: tp_double.path, line: '10', binding: tp_double.binding) }

  describe '#enable' do
    it 'enables a breakpoint' do
      breakpoint.enable

      expect(breakpoint.enabled).to be true
    end
  end

  describe '#disable' do
    it 'disables a breakpoint' do
      breakpoint.disable

      expect(breakpoint.enabled).to_not be true
    end
  end
end
