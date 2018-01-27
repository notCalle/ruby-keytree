RSpec.describe KeyTree::Forest do
  it 'is a subclass of array' do
    expect(KeyTree::Forest[]).to be_an Array
  end

  context 'when initialized' do
    before :context do
      @tree = KeyTree::Tree[a: 1]
    end

    context 'with nothing' do
      it 'does not raise an error' do
        expect { KeyTree::Forest[] }.not_to raise_error
      end

      it 'is empty' do
        expect(KeyTree::Forest[]).to be_empty
      end
    end

    context 'with a tree' do
      it 'does not raise an error' do
        expect { KeyTree::Forest[@tree] }.not_to raise_error
      end

      it 'contains the tree' do
        expect(KeyTree::Forest[@tree]).to include(@tree)
      end

      it 'can be flattened into a tree' do
        expect(KeyTree::Forest[@tree].flatten).to be_a KeyTree::Tree
      end
    end

    context 'with a forest' do
      before :context do
        @forest = KeyTree::Forest[@tree]
      end

      it 'does not raise an error' do
        expect { KeyTree::Forest[@forest] }.not_to raise_error
      end

      it 'contains the nested forest' do
        expect(KeyTree::Forest[@forest]).to include(@forest)
      end

      it 'can be flattened into a tree' do
        expect(KeyTree::Forest[@forest].flatten).to be_a KeyTree::Tree
      end
    end
  end
end
