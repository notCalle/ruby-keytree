require_relative 'forest'
require_relative 'path'
require_relative 'tree'

module KeyTree
  # KeyTree refinements to core classes
  module Refinements
    refine Array do
      def to_key_forest
        Forest[*map(&:to_key_wood)]
      end
      alias_method :to_key_wood, :to_key_forest

      def to_key_path
        Path.new(self)
      end
    end

    refine Hash do
      def to_key_tree
        Tree[self]
      end
      alias_method :to_key_wood, :to_key_tree
    end

    refine String do
      def to_key_path
        split('.').to_key_path
      end
    end

    refine Symbol do
      def to_key_path
        to_s.to_key_path
      end
    end
  end
end
