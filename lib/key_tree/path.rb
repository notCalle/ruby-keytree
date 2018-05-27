require_relative 'key_path_ext'

using KeyTree::KeyPathExt

module KeyTree
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
        result << key_path.to_key_path
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
    #   => ["a", "b", "c"]
    #
    def initialize(key_path = nil)
      case key_path
      when NilClass
        nil
      when Array
        concat(key_path.map(&:to_sym))
      else
        initialize(key_path.to_key_path)
      end
    end

    def to_key_path
      self
    end

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
      super(other.to_key_path)
    end

    # drop(+prefix+)
    #
    #   Returns a key path without the leading prefix
    #
    # drop(+n+)
    #
    #   Returns a key path without the first n elements
    #
    def drop(prefix)
      case prefix
      when Path
        return self unless prefix?(other)
        drop(other.length)
      else
        super(prefix)
      end
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
