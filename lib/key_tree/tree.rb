# frozen_string_literal: true

require 'forwardable'
require_relative 'meta_data'
require_relative 'path'
require_relative 'refinements'
require_relative 'refine/deep_hash'

module KeyTree # rubocop:disable Style/Documentation
  using Refinements
  using Refine::DeepHash

  # A tree of key-value lookup tables (hashes)
  class Tree
    include MetaData
    extend Forwardable
    #
    # KeyTree::Tree.new(+hash+)
    #
    # Initialize a new KeyTree from nested Hash:es
    #
    def self.[](hash = {})
      new(hash)
    end

    def initialize(hash = {}, default = nil, &default_proc)
      @hash = hash.to_h.deep_key_pathify
      @default = default
      @default_proc = default_proc
    end

    attr_reader :default, :default_proc

    alias to_key_tree itself
    alias to_key_wood itself

    delegate %i[empty? to_h to_json] => :@hash

    # Convert a Tree to YAML, with string keys
    #
    # :call-seq:
    #   to_yaml => String
    def to_yaml
      to_h.deep_transform_keys(&:to_s).to_yaml
    end

    def [](key_path)
      fetch_default(key_path, default)
    end

    def fetch_default(key_path, *default)
      catch do |ball|
        return fetch(key_path) { throw ball }
      end
      return default_proc.call(self, key_path) unless default_proc.nil?
      return yield(key_path) if block_given?
      return default.first unless default.empty?
      raise KeyError, %(key not found: "#{key_path}")
    end

    def fetch(key_path, *args, &key_missing)
      @hash.deep_fetch(key_path.to_key_path, *args, &key_missing)
    end

    def store(key_path, new_value)
      @hash.deep_store(key_path.to_key_path, new_value)
    end

    def store!(key_path, new_value)
      store(key_path, new_value)
    rescue KeyError
      delete!(key_path)
      retry
    end
    alias []= store!

    def delete(key_path)
      @hash.deep_delete(key_path.to_key_path)
    end

    def delete!(key_path)
      delete(key_path)
    rescue KeyError
      key_path = key_path[0..-2]
      retry
    end

    def values_at(*key_paths)
      key_paths.map { |key_path| self[key_path] }
    end

    # Return all maximal key paths in a tree
    #
    # :call-seq:
    #   keys => Array of KeyTree::Path
    def keys
      @hash.deep.each_with_object([]) do |(key_path, value), result|
        result << key_path.to_key_path unless value.is_a?(Hash)
      end
    end
    alias key_paths keys

    def include?(key_path)
      fetch(key_path)
      true
    rescue KeyError
      false
    end
    alias key? include?
    alias has_key? include?
    alias key_path? include?
    alias has_key_path? include?

    def prefix?(key_path)
      key_path.to_key_path.reduce(@hash) do |subtree, key|
        return false unless subtree.is_a?(Hash)
        return false unless subtree.key?(key)
        subtree[key]
      end
      true
    end
    alias has_prefix? prefix?

    def value?(needle)
      @hash.deep.lazy.any? { |(_, straw)| straw == needle }
    end
    alias has_value? value?

    # Merge values from +other+ tree into self
    #
    # :call-seq:
    #   merge!(other) => self
    #   merge!(other) { |key, lhs, rhs| } => self
    def merge!(other, &block)
      @hash.deep_merge!(other.to_h, &block)
      self
    end
    alias << merge!

    # Return a new tree by merging values from +other+ tree
    #
    # :call-seq:
    #   merge(other) => Tree
    #   merge(other) { |key, lhs, rhs| } => Tree
    def merge(other, &block)
      @hash.deep_merge(other.to_h, &block).to_key_tree
    end
    alias + merge
  end
end
