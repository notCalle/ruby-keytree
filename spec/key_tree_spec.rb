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

        it 'can prepend a key prefix to loaded data' do
          expect(
            KeyTree.load('pfx', loader => @t[loader])
          ).to be_a KeyTree::Tree
          expect(
            KeyTree.load('pfx', loader => @f[loader])
          ).to be_a KeyTree::Tree
        end
      end
    end

    context 'from a file' do
      %w[yaml].each do |file_type|
        context "of type #{file_type}" do
          before :context do
            @tree_fixture = fixture("tree.#{file_type}")
            @tree_expected = { 'a' => 1, 'b.c.d' => 4 }
            @forest_fixture = fixture("forest.#{file_type}")
          end

          it 'creates trees from maps' do
            expect(KeyTree.open(@tree_fixture)).to be_a KeyTree::Tree
          end

          it 'contains the expected key/values' do
            tree = KeyTree.open(@tree_fixture)
            @tree_expected.each do |key, value|
              expect(tree[key]).to eq value
            end
          end

          it 'creates forests from lists' do
            expect(KeyTree.open(@forest_fixture)).to be_a KeyTree::Forest
          end

          it 'remembers the path of loaded file' do
            expect(
              KeyTree.open(@tree_fixture).meta_data['file.path']
            ).to eq @tree_fixture
          end
        end
      end
    end

    context 'from a directory, non-recursively' do
      before :context do
        @forest = KeyTree.open_all(fixture('forest'))
      end

      it 'creates a forest' do
        expect(@forest).to be_a KeyTree::Forest
      end

      it 'has expected keys' do
        expect(@forest['b']).to eq 2
      end

      it 'does not have unexpected keys' do
        expect(@forest['a']).to be_nil
        expect(@forest['c']).to be_nil
      end
    end

    context 'from a directory, recursively' do
      before :context do
        @forest = KeyTree.open_all(fixture('forest'), recurse: true)
      end

      it 'creates a forest' do
        expect(@forest).to be_a KeyTree::Forest
      end

      it 'has expected keys' do
        expect(@forest['b']).to eq 2
        expect(@forest['c']).to eq 3
      end

      it 'does not have unexpected keys' do
        expect(@forest['a']).to be_nil
      end
    end

    context 'from a directory with unloadable files' do
      it 'raises a NoMethodError' do
        expect {
          KeyTree.open_all(fixture('danger-forest'))
        }.to raise_error NoMethodError
      end

      context 'with a fallback loader' do
        it 'does not raise an error' do
          expect {
            KeyTree::Loader.fallback(KeyTree::Loader::Nil)
            KeyTree.open_all(fixture('danger-forest'))
            KeyTree::Loader.fallback(nil)
          }.not_to raise_error
        end
      end
    end
  end
end
