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

  context 'when loading' do
    it 'requires exactly one typed serialization' do
      expect { KeyTree.load }.to raise_error ArgumentError
      expect { KeyTree.load(a: '', b: '') }.to raise_error ArgumentError
    end

    before :context do
      @t = { yaml: "---\na: 1\n",   json: '{"a": 1}'   }
      @f = { yaml: "---\n- a: 1\n", json: '[{"a": 1}]' }
    end

    %i[yaml json].each do |loader|
      context "from #{loader}" do
        it 'creates trees from maps' do
          expect(KeyTree.load(loader => @t[loader])).to be_a KeyTree::Tree
        end

        it 'creates forests from lists' do
          expect(KeyTree.load(loader => @f[loader])).to be_a KeyTree::Forest
        end

        it 'remembers the type of loaded data' do
          expect(
            KeyTree.load(loader => @t[loader]).meta_data['load.type']
          ).to eq loader
        end
      end
    end
      end
    end
  end
end
