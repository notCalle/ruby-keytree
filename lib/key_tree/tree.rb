require_relative 'meta_data'
require_relative 'path'
require_relative 'refinements'

module KeyTree # rubocop:disable Style/Documentation
  using Refinements

  # A tree of key-value lookup tables (hashes)
  class Tree < Hash # rubocop:disable Metrics/ClassLength
    include MetaData
    #
    # KeyTree::Tree.new(+hash+)
    #
    # Initialize a new KeyTree from nested Hash:es
    #
    def self.[](hash = {})
      return hash if hash.is_a?(Tree)

      hash.each_with_object(Tree.new) do |(key, value), keytree|
        keytree[key] = value
      end
    end

    alias to_key_tree itself
    alias to_key_wood itself

    def [](key_path)
      fetch(key_path) do
        default_proc.call(self, key_path) unless default_proc.nil?
      end
    rescue KeyError
      default
    end

    def fetch(key_path, *args, &key_missing)
      first_key, *rest_path = key_path.to_key_path
      result = super(first_key, *args, &key_missing)
      unless result.is_a?(Tree)
        return result if rest_path.empty?
        raise KeyError, %(key not found: "#{key_path}")
      end
      raise KeyError, %(key not found: "#{key_path}") if rest_path.empty?
      result.fetch(rest_path, *args, &key_missing)
    end

    def values_at(*key_paths)
      key_paths.map { |key_path| self[key_path] }
    end

    def []=(key_path, new_value)
      key_path = key_path.to_key_path

      if key_path.one?
        new_value = new_value.to_key_tree if new_value.is_a?(Hash)
        super(key_path.first, new_value)
      else
        deposit(*key_path, new_value)
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
    alias key_path? include?
    alias has_key_path? include?

    def prefix?(key_path)
      key_path.to_key_path.reduce(self) do |subtree, key|
        return false unless subtree.is_a?(Tree)
        return false unless subtree.key?(key)
        subtree[key]
      end
      true
    end
    alias has_prefix? prefix?

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

    private

    # Deposit a new value at a key path.
    #
    # :call-seq:
    #   depisit(*key_path, new_value)
    def deposit(*prefix_path, last_key, new_value)
      prefix_tree = prefix_path.reduce(self) do |subtree, key|
        next subtree[key] = Tree.new unless subtree[key].is_a?(Tree)
        subtree[key]
      end
      prefix_tree[last_key] = new_value
    end
  end
end
