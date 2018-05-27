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

      it 'can get the expected values for keys' do
        expect(KeyTree::Forest[@tree]['a']).to eq 1
      end

      it 'returns nil for undefined keys' do
        expect(KeyTree::Forest[@tree]['b']).to be_nil
      end

      it 'can be flattened into a tree' do
        expect(KeyTree::Forest[@tree].flatten).to be_a KeyTree::Tree
      end

      context 'that has a default proc' do
        before :context do
          @tree = KeyTree::Tree.new { |*| true }
          @forest = KeyTree::Forest[@tree]
        end

        it 'can return default values for missing keys' do
          expect { @forest.fetch('a') }.to raise_error KeyError
          expect(@forest['a']).to be true
        end
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

    context 'with trees and forests' do
      before :context do
        @tree1 = KeyTree::Tree[a: 1]
        @tree2 = KeyTree::Tree[a: { b: 2 }]
        @forest1 = KeyTree::Forest[@tree1]
      end

      it 'does not raise an error' do
        expect { KeyTree::Forest[@forest1, @tree2] }.not_to raise_error
      end

      before :example do
        @forest = KeyTree::Forest[@forest1, @tree2]
      end

      it 'contains the tree' do
        expect(@forest).to include(@tree2)
      end

      it 'contains the nested forest' do
        expect(@forest).to include(@forest1)
      end

      it 'can get the expected values for keys' do
        expect(KeyTree::Forest[@tree]['a']).to eq 1
      end

      it 'returns nil for undefined keys' do
        expect(KeyTree::Forest[@tree]['b']).to be_nil
      end

      it 'hides forests behind trees' do
        expect(@forest['a']).to eq @tree2['a']
        expect(@forest['a.b']).to eq @tree2['a.b']
      end
    end
  end
end
