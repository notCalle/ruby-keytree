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
      case key
      when Numeric
        super(key)
      else
        trees.detect do |tree|
          return tree[key] if tree.key?(key)
          return nil if tree.prefix?(key)
        end
      end
    end

    def key?(key)
      any? { |tree_or_forest| tree_or_forest.key?(key) }
    end

    def prefix?(key)
      any? { |tree_or_forest| tree_or_forest.prefix?(key) }
    end

    # Flattening a forest produces a tree with the equivalent view of key paths
    #
    def flatten
      trees.reverse_each.reduce(Tree[], :merge!)
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
