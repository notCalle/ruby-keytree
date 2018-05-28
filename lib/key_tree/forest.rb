require_relative 'meta_data'
require_relative 'refinements'
require_relative 'tree'

module KeyTree # rubocop:disable Style/Documentation
  using Refinements

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
      trees.lazy.map { |tree| tree[key] }.detect { |value| !value.nil? }
    end

    def fetch(key)
      return tree_with_key(key).fetch(key) unless block_given?

      values = trees_with_key(key).map { |tree| tree.fetch(key) }
      values.reverse.reduce { |left, right| yield(key, left, right) }
    end

    def key?(key)
      trees.lazy.any? { |tree| tree.key?(key) }
    end
    alias has_key? key?

    def prefix?(key)
      trees.lazy.any? { |tree| tree.prefix?(key) }
    end
    alias has_prefix? prefix?

    def key_path?(key)
      trees.lazy.any? { |tree| tree.key_path?(key) }
    end
    alias has_key_path? key_path?

    def include?(needle)
      case needle
      when Tree, Forest
        super(needle)
      else
        key_path?(needle)
      end
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

    # Return all visible key paths in the forest
    def key_paths
      trees.reduce(Set.new) { |result, tree| result.merge(tree.key_paths) }
    end

    private

    def tree_with_key(key)
      result = trees.lazy.detect do |tree|
        tree.prefix?(key)
      end
      result || raise(KeyError, %(key not found: "#{key}"))
    end

    def trees_with_key(key)
      result = trees.select do |tree|
        tree.prefix?(key)
      end
      raise(KeyError, %(key not found: "#{key}")) if result.empty?
      result
    end
  end
end
