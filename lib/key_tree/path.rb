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
    def self.[](*keys_or_paths)
      keys_or_paths.reduce(Path.new) do |result, key_or_path|
        result << Path.new(key_or_path)
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
    def initialize(key_or_path = [])
      case key_or_path
      when String
        initialize(key_or_path.split('.'))
      when Symbol
        initialize(key_or_path.to_s)
      when Array
        key_or_path.each { |key| append(key.to_sym) }
      else
        raise ArgumentError, 'key path must be String, Symbol or Array of those'
      end
    end

    def to_s
      join('.')
    end

    def inspect
      %("#{self}")
    end

    def <<(other)
      case other
      when Path
        other.reduce(self) do |result, key|
          result.append(key)
        end
      else
        self << Path[other]
      end
    end

    def +(other)
      dup << other
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
    def prefix?(other)
      return false if other.length > length
      key_enum = each
      other.all? { |other_key| key_enum.next == other_key }
    end

    # Would +other+ conflict?
    #
    def conflict?(other)
      prefix?(other) || other.prefix?(self) if self != other
    end
  end
end
