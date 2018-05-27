require 'key_tree/path'
require 'key_tree/meta_data'
require_relative 'key_path_ext'

using KeyTree::KeyPathExt

module KeyTree
  # A tree of key-value lookup tables (hashes)
  class Tree < Hash
    include MetaData
    #
    # KeyTree::Tree.new(+hash+)
    #
    # Initialize a new KeyTree from nested Hash:es
    #
    def self.[](hash = {})
      return hash if hash.is_a?(Tree)

      hash.each_with_object(Tree.new) do |(key, value), keytree|
        value = Tree[value] if value.is_a?(Hash)
        keytree[key] = value
      end
    end

    def [](key_path)
      fetch(key_path) do
        default_proc.call(self, key_path) unless default_proc.nil?
      end
    rescue KeyError
      default
    end

    def fetch(key_path, *args, &key_missing)
      key_path.to_key_path.reduce(self) do |subtree, key|
        next super(key, *args, &key_missing) if subtree.equal?(self)
        next subtree.fetch(key, *args, &key_missing) if subtree.is_a?(Hash)
        return yield(key_path) if block_given?
        raise KeyError, %(key not found: "#{key_path}")
      end
    end

    def values_at(*key_paths)
      key_paths.map { |key_path| self[key_path] }
    end

    def []=(key_path, new_value)
      *prefix_path, last_key = key_path.to_key_path
      if prefix_path.empty?
        super(last_key, new_value)
      else
        prefix_tree = prefix_path.reduce(self) do |subtree, key|
          next subtree[key] = {} unless subtree[key].is_a?(Hash)
          subtree[key]
        end
        prefix_tree[last_key] = new_value
      end
    end

    # Return all maximal key paths in a tree
    #
    # :call-seq:
    #   key_paths => Array of KeyTree::Path
    def key_paths
      each_with_object([]) do |(key, value), result|
        key = key.to_key_path
        next result << key unless value.is_a?(Tree)
        subkeys = value.key_paths
        result.concat(subkeys.map { |path| key + path })
      end
    end

    def include?(key_path)
      key_paths.include?(key_path.to_key_path)
    end

    def prefix?(key_path)
      key_path.to_key_path.reduce(self) do |subtree, key|
        return false unless subtree.is_a?(Tree)
        return false unless subtree.key?(key)
        subtree[key]
      end
      true
    end

    def value?(needle)
      return true if super(needle)
      values.any? { |straw| straw.value?(needle) if straw.is_a?(Tree) }
    end
    alias has_value? value?

    # The merging of trees needs some extra consideration; due to the
    # nature of key paths, prefix conflicts must be deleted
    #
    def merge!(other)
      other = Tree[other] unless other.is_a?(Tree)
      super(other) do |key, lhs, rhs|
        next lhs.merge!(rhs) if lhs.is_a?(Hash) && rhs.is_a?(Hash)
        next yield(key, lhs, rhs) if block_given?
        rhs
      end
    end
    alias << merge!

    def merge(other)
      super(other) do |key, lhs, rhs|
        next lhs.merge(rhs) if lhs.is_a?(Hash) && rhs.is_a?(Hash)
        next yield(key, lhs, rhs) if block_given?
        rhs
      end
    end
    alias + merge

    # Convert a Tree back to nested hashes.
    #
    # :call-seq:
    #   to_h => Hash, with symbol keys
    #   to_h(stringify_keys: true) => Hash, with string keys
    def to_h(stringify_keys: false)
      transform = stringify_keys ? :to_s : :itself
      deep_transform_keys(&transform)
    end

    # Convert a Tree to JSON, with string keys
    #
    # :call-seq:
    #   to_json => String
    def to_json
      deep_transform_keys(&:to_s).to_json
    end

    # Convert a Tree to YAML, with string keys
    #
    # :call-seq:
    #   to_yaml => String
    def to_yaml
      deep_transform_keys(&:to_s).to_yaml
    end

    # Transform keys, returning a nested Hash
    #
    # :call-seq:
    #   deep_transform_keys { |key| block } => Hash
    def deep_transform_keys(&transform)
      each_with_object({}) do |(key, value), result|
        value = value.deep_transform_keys(&transform) if value.is_a?(Tree)
        result[yield(key)] = value
      end
    end
  end
end
