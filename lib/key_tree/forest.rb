# frozen_string_literal: true

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
        result << content.to_key_wood
      end
    end

    alias to_key_forest itself
    alias to_key_wood itself

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

      trees.lazy.each do |tree|
        result = tree[key]
        return result unless result.nil?
        break if tree.prefix?(key)
      end
      nil
    end

    # Fetch a value from a forest
    #
    # :call-seq:
    #   fetch(key) => value
    #   fetch(key, default) => value
    #   fetch(key) { |key| } => value
    #
    # The first form raises a +KeyError+ unless +key+ has a value.
    def fetch(key, *default)
      trees.lazy.each do |tree|
        catch do |ball|
          return tree.fetch(key) { throw ball }
        end
      end
      return yield(key) if block_given?
      return default.first unless default.empty?

      raise KeyError, %(key not found: "#{key}")
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
  end
end
