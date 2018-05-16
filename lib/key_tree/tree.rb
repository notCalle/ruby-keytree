require 'key_tree/path'
require 'key_tree/meta_data'

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
      keytree = Tree.new
      hash.each do |key, value|
        keytree[key] = value
      end
      keytree
    end

    def [](key_or_path)
      super(Path[key_or_path])
    end

    def fetch(key_or_path, *args, &proc)
      super(Path[key_or_path], *args, &proc)
    end

    def values_at(*keys)
      super(keys.map { |key_or_path| Path[key_or_path] })
    end

    def []=(key_or_path, new_value)
      path = Path[key_or_path]

      delete_if { |key, _| path.conflict?(key) }

      case new_value
      when Hash
        new_value.each { |suffix, value| self[path + suffix] = value }
      else
        super(path, new_value)
      end
    end

    def key?(key_or_path)
      super(Path[key_or_path])
    end

    def default_key?(key_or_path)
      return unless default_proc
      default_proc.yield(self, Path[key_or_path])
      true
    rescue KeyError
      false
    end

    def prefix?(key_or_path)
      keys.any? { |key| key.prefix?(Path[key_or_path]) }
    end

    def conflict?(key_or_path)
      keys.any? { |key| key.conflict?(Path[key_or_path]) }
    end

    # The merging of trees needs some extra consideration; due to the
    # nature of key paths, prefix conflicts must be deleted
    #
    def merge!(other, &merger)
      other = Tree[other] unless other.is_a?(Tree)
      delete_if { |key, _| other.conflict?(key) }
      super
    end
    alias << merge!

    def merge(other, &merger)
      dup.merge!(other, &merger)
    end
    alias + merge

    # Format +fmtstr+ with values from the Tree
    def format(fmtstr)
      Kernel.format(fmtstr, Hash.new { |_, key| fetch(key) })
    end

    # Convert a Tree back to nested hashes.
    #
    # to_h => Hash, with symbol keys
    # to_h(string_keys: true) => Hash, with string keys
    def to_h(**kwargs)
      to_hash_tree(**kwargs)
    end

    # Convert a Tree to JSON, with string keys
    def to_json
      to_hash_tree(string_keys: true).to_json
    end

    # Convert a Tree to YAML, with string keys
    def to_yaml
      to_hash_tree(string_keys: true).to_yaml
    end

    private

    def to_hash_tree(key_pairs = self, string_keys: false)
      hash = key_pairs.group_by do |path, _|
        string_keys ? path.first.to_s : path.first
      end
      hash.transform_values do |next_level|
        next_level.map! { |path, value| [path[1..-1], value] }
        first_key, first_value = next_level.first
        next first_value if first_key.nil? || first_key.empty?
        to_hash_tree(next_level)
      end
    end
  end
end
