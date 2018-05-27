module KeyTree
  # KeyTree::Path refinements to core classes
  module KeyPathExt
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

    refine Array do
      def to_key_path
        Path.new(self)
      end
    end
  end
end
