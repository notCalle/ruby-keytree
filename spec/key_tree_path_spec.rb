# frozen_string_literal: true

require 'key_tree/path'

RSpec.describe KeyTree::Path do
  it 'is a subclass of array' do
    expect(KeyTree::Path.new).to be_an Array
  end

  context 'when initialized' do
    context 'with nothing' do
      it 'does not raise an error' do
        expect { KeyTree::Path[] }.not_to raise_error
      end

      it 'is empty' do
        expect(KeyTree::Path[]).to be_empty
      end
    end

    context 'with a symbol' do
      before :context do
        @symbol = :a
      end

      it 'does not raise an error' do
        expect { KeyTree::Path[@symbol] }.not_to raise_error
      end

      it 'includes the symbol' do
        expect(KeyTree::Path[@symbol]).to include @symbol
      end
    end

    context 'with an array' do
      context 'of symbols' do
        before :context do
          @symbols = %i[a b]
        end

        it 'does not raise an error' do
          expect { KeyTree::Path[@symbols] }.not_to raise_error
        end

        it 'includes all the symbols' do
          @symbols.each do |symbol|
            expect(KeyTree::Path[@symbols]).to include symbol
          end
        end
      end
    end

    context 'with a string' do
      context 'that is a simple key' do
        before :context do
          @string = 'a'
        end

        it 'does not raise an error' do
          expect { KeyTree::Path[@string] }.not_to raise_error
        end

        it 'includes the key as a symbol' do
          expect(KeyTree::Path[@string]).to include @string.to_sym
        end

        it 'has a string representation equal to the string' do
          expect(KeyTree::Path[@string].to_s).to eq @string
        end

        it 'can be inspected like a string' do
          expect(KeyTree::Path[@string].inspect).to eq @string.inspect
        end
      end

      context 'that is a dot-separated path of keys' do
        before :context do
          @string = 'a.b'
          @keys = @string.split('.').map(&:to_sym)
        end

        it 'does not raise an error' do
          expect { KeyTree::Path[@string] }.not_to raise_error
        end

        it 'includes all keys in the path as symbols' do
          @keys.each do |key|
            expect(KeyTree::Path[@string]).to include key
          end
        end

        it 'is equivalent to initializing from an array of symbols' do
          expect(KeyTree::Path[@string]).to eq KeyTree::Path[@keys]
        end

        it 'has a string representation equal to the string' do
          expect(KeyTree::Path[@string].to_s).to eq @string
        end

        it 'can be inspected like a string' do
          expect(KeyTree::Path[@string].inspect).to eq @string.inspect
        end
      end
    end
  end

  context 'when concatenated' do
    before :context do
      @keypath = KeyTree::Path[:a]
    end

    context 'with a symbol' do
      before :context do
        @symbol = :b
      end

      it 'does not raise an error' do
        expect { @keypath + @symbol }.not_to raise_error
      end

      it 'includes the symbol' do
        expect(@keypath + @symbol).to include @symbol
      end
    end

    context 'with an array of symbols' do
      before :context do
        @symbols = %i[b c]
      end

      it 'does not rais an error' do
        expect { @keypath + @symbols }.not_to raise_error
      end

      it 'includes all the symbols' do
        @symbols.each do |symbol|
          expect(@keypath + @symbols).to include symbol
        end
      end
    end

    context 'with a string' do
      context 'that is a simple key' do
        before :context do
          @string = 'b'
        end

        it 'does not raise an error' do
          expect { @keypath + @string }.not_to raise_error
        end

        it 'includes the key as a symbol' do
          expect(@keypath + @string).to include @string.to_sym
        end
      end

      context 'that is a dot-separated path of keys' do
        before :context do
          @string = 'b.c'
          @keys = @string.split('.').map(&:to_sym)
        end

        it 'does not raise an error' do
          expect { @keypath + @string }.not_to raise_error
        end

        it 'includes all keys in the path as symbols' do
          @keys.each do |key|
            expect(@keypath + @string).to include key
          end
        end

        it 'is equivalent to concatenating with an array of symbols' do
          expect(@keypath + @string).to eq(@keypath + @keys)
        end
      end
    end
  end

  it 'can detect conflicting key path overlaps', :aggregate_failures do
    path1 = KeyTree::Path['a.b.c']
    path2 = KeyTree::Path['a.b']

    expect(path1.conflict?(path2)).to be true
    expect(path2.conflict?(path1)).to be true
  end

  it 'can drop a prefix from a key path' do
    path1 = KeyTree::Path['a.b.c']
    path2 = KeyTree::Path['a.b']

    expect(path1.drop(path2)).to eq KeyTree::Path['c']
  end
end
