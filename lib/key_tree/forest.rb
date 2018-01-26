require 'key_tree/tree'

module KeyTree
  #
  # A forest is a (possibly nested) collection of trees
  #
  class Forest < Array
    def self.[](contents = [])
      contents.reduce(Forest.new) do |result, content|
        result << KeyTree[content]
      end.sort!
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
        each do |tree_or_forest|
          return tree_or_forest[key] if tree_or_forest.include?(key)
          return nil if tree_or_forest.include_prefix?(key)
        end
      end
    end

    # Trees are always smaller than forrests.
    # Forests are compared by nesting depth, not number of trees.
    #
    def <=>(other)
      return 0 if self == other

      case other
      when Forest
        depth <=> other.depth
      when Tree
        1
      else
        raise ArgumentError, 'only forests and trees are comparable'
      end
    end

    # The nesting depth of a forest
    def depth
      reduce(1) do |result, tree_or_forest|
        [result, content_depth(tree_or_forest) + 1].max
      end
    end

    def include?(key)
      any? { |tree_or_forest| tree_or_forest.include?(key) }
    end

    def include_prefix?(key)
      any? { |tree_or_forest| tree_or_forest.include_prefix?(key) }
    end

    def flatten
      reduce do |result, tree_or_forest|
        tree_or_forest.merge(result)
      end
    end

    private

    def content_depth(content)
      case content
      when Forest
        content.depth
      else
        0
      end
    end
  end
end
