# frozen_string_literal: true

require_relative 'refinements'

module KeyTree # rubocop:disable Style/Documentation
  using Refinements

  #
  # Representation of the key path to a value in a key tree
  #
  class Path < Array
    #
    # KeyTree::Path[+key_or_path+, ...]
    #
    # Make a new key path from one or more keys or paths
    #
    def self.[](*key_paths)
      key_paths.reduce(Path.new) do |result, key_path|
        result << Path.new(key_path)
      end
    end

    #
    # KeyTree::Path.new(+key_or_path+)
    #
    # Make a new key path from a dot separated string, single symbol,
    # or array of strings or symbols.
    #
    # Example:
    #   KeyTree::Path.new("a.b.c")
    #   => [:a, :b, :c]
    #
    def initialize(key_path = [])
      key_path = key_path.to_key_path unless key_path.is_a? Array

      super(key_path.map(&:to_sym))
    end

    alias to_key_path itself

    def to_s
      join('.')
    end

    def inspect
      %("#{self}")
    end

    def <<(other)
      concat(other.to_key_path)
    end

    def +(other)
      dup.concat(other.to_key_path)
    end

    # Returns a key path without the leading +prefix+
    #
    # :call-seq:
    #   drop(other) => Path
    def drop(other)
      other = other.to_key_path
      raise KeyError unless prefix?(other)

      super(other.length)
    end

    # Is +other+ a prefix?
    #
    # :call-seq:
    #   prefix?(other) => boolean
    def prefix?(other)
      other = other.to_key_path
      return false if other.length > length

      key_enum = each
      other.all? { |other_key| key_enum.next == other_key }
    end
    alias === prefix?

    # Would +other+ conflict?
    #
    def conflict?(other)
      prefix?(other) || other.prefix?(self) if self != other
    end
  end
end
