# frozen_string_literal: true

require 'key_tree/refine/deep_hash'

RSpec.describe KeyTree::Refine::DeepHash do
  using described_class

  it { should be_a Module }

  context 'refines Hash with' do
    let(:hash) { { a: { b: 1, c: 2 }, b: 3 } }
    let(:expected_deep) do
      [[%i[a], hash[:a]],
       [%i[a b], hash[:a][:b]],
       [%i[a c], hash[:a][:c]],
       [%i[b], hash[:b]]]
    end

    context '#deep' do
      subject { hash.deep }

      it 'traverses the hash tree' do
        expect { |b| subject.each(&b) }.to yield_control.exactly(4).times
      end

      it 'yields all key paths and values in the hash tree, depth-first' do
        expect { |b| subject.each(&b) }.to yield_successive_args(*expected_deep)
      end
    end

    context '#deep_fetch' do
      it 'fetches a value by key path' do
        expect(hash.deep_fetch(%i[a b])).to be hash[:a][:b]
      end

      it 'raises a KeyError for a missing key path' do
        expect { hash.deep_fetch(%i[d]) }.to raise_error KeyError
      end

      it 'returns a default value for a missing key path, if given' do
        expect(hash.deep_fetch(%i[d], 7)).to eq 7
      end

      it 'yields a missing key path to a block, if given' do
        expect { |b| hash.deep_fetch(%i[d], &b) }.to yield_successive_args([:d])
      end
    end

    context '#deep_store' do
      it 'stores a value by key path' do
        hash.deep_store(%i[a b], 0)
        expect(hash.deep_fetch(%i[a b])).to be 0
      end

      it 'raises a KeyError for a conflicting key path' do
        expect { hash.deep_store(%i[a b c], 0) }.to raise_error KeyError
      end
    end

    context '#deep_delete' do
      it 'returns the value of the deleted key path', :aggregate_failures do
        previous_value = hash.deep_fetch(%i[a b])
        deleted_value = hash.deep_delete(%i[a b])
        expect { hash.deep_fetch(%i[a b]) }.to raise_error KeyError
        expect(deleted_value).to eq previous_value
      end

      it 'returns nil for a missing key path' do
        expect(hash.deep_delete(%i[a z])).to be_nil
      end

      it 'raises a KeyError for a conflicting key path' do
        expect { hash.deep_delete(%i[a b c]) }.to raise_error KeyError
      end
    end

    let(:update) { { a: { b: 2, d: 4 } } }
    let(:updated_deep) do
      [[%i[a], { b: 2, c: 2, d: 4 }],
       [%i[a b], 2],
       [%i[a c], 2],
       [%i[a d], 4],
       [%i[b], 3]]
    end

    context '#deep_merge!' do
      it 'replaces values in the original hash tree' do
        hash.deep_merge! update
        expect { |b|
          hash.deep.each(&b)
        }.to yield_successive_args(*updated_deep)
      end

      it 'can defer value selection to a block' do
        expect { |b|
          hash.deep_merge!(update, &b)
        }.to yield_successive_args([%i[a b], 1, 2])
      end
    end

    context '#deep_merge' do
      it 'returns a new hash with updated values' do
        expect { |b|
          hash.deep_merge(update).deep.each(&b)
        }.to yield_successive_args(*updated_deep)
      end

      it 'does not replace values in the original hash tree' do
        hash.deep_merge update
        expect { |b|
          hash.deep.each(&b)
        }.to yield_successive_args(*expected_deep)
      end

      it 'can defer value selection to a block' do
        expect { |b|
          hash.deep_merge(update, &b)
        }.to yield_successive_args([%i[a b], 1, 2])
      end
    end

    context '#deep_transform_keys' do
      pending 'tests not implemented'
    end

    context '#deep_transform_keys!' do
      pending 'tests not implemented'
    end

    context '#deep_key_pathify' do
      pending 'tests not implemented'
    end
  end
end
