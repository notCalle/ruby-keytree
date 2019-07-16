# frozen_string_literal: true

require 'key_tree/tree'

RSpec.describe KeyTree::Tree do
  context 'when initialized' do
    context 'with nothing' do
      it 'does not raise an error' do
        expect { KeyTree::Tree[] }.not_to raise_error
      end

      it 'is empty' do
        expect(KeyTree::Tree[]).to be_empty
      end
    end

    context 'with a default proc' do
      before :context do
        @keytree = KeyTree::Tree.new { true }
      end

      it 'can fetch default values for missing keys' do
        expect { @keytree.fetch('a') }.to raise_error KeyError
        expect(@keytree['a']).to be true
      end
    end

    context 'with a hash' do
      before :context do
        @hash = { a: 1, b: { c: 2 } }
        @str_hash = { 'a' => 1, 'b' => { 'c' => 2 } }
        @keys = %w[a b.c]
        @key_prefixes = %w[b]
        @values = 1.upto(2)
      end

      it 'does not raise an error' do
        expect { KeyTree::Tree[@hash] }.not_to raise_error
      end

      before :example do
        @keytree = KeyTree::Tree[@hash]
      end

      it 'includes the expected key paths' do
        @keys.each do |key|
          expect(@keytree).to have_key_path(key)
        end
      end

      it 'includes the expected values' do
        @values.each do |value|
          expect(@keytree).to have_value(value)
        end
      end

      it 'does not include key prefixes' do
        @key_prefixes.each do |key|
          expect(@keytree).to have_prefix(key)
          expect(@keytree).not_to have_key_path(key)
          expect(@keytree[key]).to be nil
        end
      end

      it 'can fetch values for key paths' do
        @keys.each do |key|
          expect(@keytree[key]).to eq @values.next
        end
      end

      it 'can return an equivalent hash, with symbol keys' do
        expect(@keytree.to_h).to eq @hash
      end

      it 'can return a JSON serialization' do
        expect(@keytree.to_json).to eq @str_hash.to_json
      end

      it 'can return a YAML serialization' do
        expect(@keytree.to_yaml).to eq @str_hash.to_yaml
      end

      it 'can fetch the list of values at some key paths' do
        expect(@keytree.values_at(*@keys)).to eq @values.to_a
      end
    end

    context 'when merged' do
      subject { KeyTree::Tree[a: { b: 1 }, c: 2] }
      let(:other) { KeyTree::Tree[a: { b: 2, c: 3 }, c: { d: 4 }] }
      let(:key_paths) { other.key_paths }

      it 'returns a key tree' do
        expect(subject.merge(other)).to be_a KeyTree::Tree
      end

      it 'contains the new keys' do
        expect(subject.merge(other).key_paths).to match key_paths
      end

      it 'contains the new values' do
        expect(
          subject.merge(other).values_at(*key_paths)
        ).to match other.values_at(*key_paths)
      end
    end

    context 'with a hash, having key_pathey keys' do
      before :context do
        @hash = { 'a.b' => 2, %i[a c] => 3 }
        @keypaths = @hash.keys.map { |key| KeyTree::Path[key] }
        @values = @hash.values
        @keytree = KeyTree::Tree[@hash]
      end

      it 'contains the expected key paths' do
        @keypaths.each do |key_path|
          expect(@keytree).to have_key key_path
        end
      end

      it 'contains the expected values' do
        @values.each do |value|
          expect(@keytree).to have_value value
        end
      end

      it 'can fetch values for key paths' do
        @hash.each do |key_path, value|
          expect(@keytree.fetch(key_path)).to eq value
        end
      end

      it 'can fetch the list of values at some key paths' do
        expect(@keytree.values_at(*@hash.keys)).to eq @hash.values
      end
    end
  end

  context 'when assigning values to keys' do
    before :example do
      @keytree = KeyTree::Tree[a: { b: 2 }]
    end

    it 'does not delete sibling keys' do
      @keytree['a.c'] = 3
      expect(@keytree).to have_key_path('a.b')
    end

    it 'deletes child keys' do
      @keytree['a'] = 1
      expect(@keytree).not_to have_key_path('a.b')
    end

    it 'overwrites values for deeper keys' do
      @keytree['a.b.c'] = 1
      expect(@keytree).not_to have_key_path('a.b')
      expect(@keytree).to have_key_path('a.b.c')
    end
  end
end
