require 'key_tree/tree'
require 'key_tree/meta_data'

module KeyTree
  #
  # A forest is a (possibly nested) collection of trees
  #
  class Forest < Array
    include MetaData

    def self.[](*contents)
      contents.reduce(Forest.new) do |result, content|
        result << KeyTree[content]
      end
    end

    # For a numeric key, return the n:th tree in the forest
    #
    # For a key path convertable key, return the closest match in the forest
    #
    # When a closer tree contains a prefix of the key, this shadows any
    # key path matches in trees further away, returning nil. This preserves
    # the constraints that only leaves may contain a value.
    #
    def [](key)
      return super(key) if key.is_a?(Numeric)
      fetch(key)
    rescue KeyError
      nil
    end

    def fetch(key)
      tree_with_key(key).fetch(key)
    end

    def tree_with_key(key)
      result = trees.detect { |tree| tree.prefix?(key) }
      result || raise(KeyError, "key not found: #{key}")
    end

    def key?(key)
      trees.any? { |tree| tree.key?(key) }
    end

    def prefix?(key)
      trees.any? { |tree_or_forest| tree_or_forest.prefix?(key) }
    end

    # Flattening a forest produces a tree with the equivalent view of key paths
    #
    def flatten(&merger)
      trees.reverse_each.reduce(Tree[]) do |result, tree|
        result.merge!(tree, &merger)
      end
    end

    # Return a breadth-first Enumerator for all the trees in the forest,
    # and any nested forests
    def trees
      Enumerator.new do |yielder|
        remaining = [self]
        remaining.each do |woods|
          next yielder << woods if woods.is_a?(Tree)
          woods.each { |wood| remaining << wood }
        end
      end
    end
  end
end
