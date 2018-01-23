require 'key_tree/path'

module KeyTree
  # A tree of key-value lookup tables (hashes)
  class Tree < Hash
    #
    # KeyTree::Tree.new(+hash+)
    #
    # Initialize a new KeyTree from nested Hash:es
    #
    def self.[](hash = {})
      keytree = Tree.new
      hash.each do |key, value|
        keytree[Path[key]] = tree_or_leaf(value)
      end
      keytree
    end

    def [](key_or_path)
      fetch(key_or_path)
    rescue KeyError
      nil
    end

    def fetch(key_or_path, *args, **kvargs, &proc)
      super(Path[key_or_path], *args, **kvargs, &proc)
    end

    def values_at(*keys)
      super(keys.map { |key_or_path| Path[key_or_path] })
    end

    def []=(key_or_path, value)
      path = Path[key_or_path]

      each_key do |key|
        if path.prefix?(key) or key.prefix?(path)
          delete(key)
        end
      end

      case value
      when KeyTree
        each_value { |suffix, value| super(path + suffix, value) }
      else
        super(path, value)
      end
    end

    private

    def tree_or_leaf(value)
      case value
      when Hash
        Tree[value]
      else
        value
      end
    end
  end
end
