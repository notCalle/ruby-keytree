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
        keytree[key] = value
      end
      keytree
    end

    def [](key_or_path)
      super(Path[key_or_path])
    end

    def fetch(key_or_path, *args, **kvargs, &proc)
      super(Path[key_or_path], *args, **kvargs, &proc)
    end

    def values_at(*keys)
      super(keys.map { |key_or_path| Path[key_or_path] })
    end

    def []=(key_or_path, new_value)
      path = Path[key_or_path]

      each_key { |key| delete(key) if path.conflict?(key) }

      case new_value
      when Hash
        new_value.each { |suffix, value| super(path + suffix, value) }
      else
        super(path, new_value)
      end
    end
  end
end
