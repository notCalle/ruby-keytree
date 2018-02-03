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
        new_value.each { |suffix, value| super(path + suffix, value) }
      else
        super(path, new_value)
      end
    end

    def key?(key_or_path)
      super(Path[key_or_path])
    end

    def prefix?(key_or_path)
      keys.any? { |key| key.prefix?(Path[key_or_path]) }
    end

    def conflict?(key_or_path)
      keys.any? { |key| key.conflict?(Path[key_or_path]) }
    end

    # All trees are created equal. Forests are always larger than trees.
    #
    def <=>(other)
      case other
      when Forest
        -1
      when Tree
        0
      else
        raise ArgumentError, 'only trees and forests are comparable'
      end
    end

    # The merging of trees needs some extra consideration; due to the
    # nature of key paths, prefix conflicts must be deleted
    #
    def merge!(other)
      other = Tree[other] unless other.is_a?(Tree)
      delete_if { |key, _| other.conflict?(key) }
      super
    end
    alias << merge!

    def merge(other)
      dup.merge!(other)
    end
    alias + merge
  end
end
