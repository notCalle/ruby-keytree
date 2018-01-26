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

    context 'with a hash' do
      before :context do
        @hash = { a: 1, b: { c: 2 } }
        @keys = %w[a b.c].map { |key| KeyTree::Path[key] }
        @key_prefixes = %w[b].map { |key| KeyTree::Path[key] }
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
          expect(@keytree).to include(key)
        end
      end

      it 'includes the expected values' do
        @values.each do |value|
          expect(@keytree).to have_value(value)
        end
      end

      it 'does not include key prefixes' do
        @key_prefixes.each do |key|
          expect(@keytree).not_to include(key)
        end
      end

      it 'can fetch values for key paths' do
        @keys.each do |key|
          expect(@keytree[key]).to eq @values.next
        end
      end
    end
  end
end
