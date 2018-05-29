# frozen_string_literal: true

module KeyTree
  module Loader
    # KeyTree loader that ignores payload and produces an empty tree
    module Nil
      def self.load(*_drop)
        {}
      end
    end
  end
end
