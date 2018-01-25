RSpec.describe KeyTree do
  it 'has a version number' do
    expect(KeyTree::VERSION).not_to be nil
  end

  it 'can create a key tree' do
    expect { KeyTree[] }.not_to raise_error
    expect(KeyTree[]).to be_a KeyTree::Tree
  end

  context 'when creating' do
    context 'from a hash' do
      it 'returns a tree' do
        expect(KeyTree[{}]).to be_a KeyTree::Tree
      end
    end
  end
end
