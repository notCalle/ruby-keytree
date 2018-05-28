RSpec.describe KeyTree::Tree do
  it 'is a subclass of hash' do
    expect(KeyTree::Tree.new).to be_a Hash
  end

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

      it 'can return an equivalent hash, with string keys' do
        expect(@keytree.to_h(stringify_keys: true)).to eq @str_hash
      end

      it 'can return a JSON serialization' do
        expect(@keytree.to_json).to eq @str_hash.to_json
      end

      it 'can return a YAML serialization' do
        expect(@keytree.to_yaml).to eq @str_hash.to_yaml
      end
    end
  end
end
