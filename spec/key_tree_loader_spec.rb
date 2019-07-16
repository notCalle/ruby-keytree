# frozen_string_literal: true

require 'json'
require 'yaml'
require 'key_tree/loader'

RSpec.describe KeyTree::Loader do
  it { should be_a Module }

  described_class::BUILTIN_LOADERS.each do |load_type, loader|
    it "provides a builtin loader for #{load_type}" do
      expect(described_class[load_type]).to eq Kernel.const_get(loader)
    end
  end

  it 'can add new loaders', :aggregate_failure do
    expect(described_class[:test_module]).to be_nil
    described_class[:test_module] = Module.new
    expect(described_class[:test_module]).not_to be_nil
  end
end
