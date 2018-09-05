# frozen_string_literal: true

require 'key_tree/loader/nil'

module KeyTree
  # Module to manage key tree loaders
  module Loader
    BUILTIN_LOADERS = {
      json: 'JSON',
      yaml: 'YAML', yml: 'YAML'
    }.freeze

    class << self
      def [](type)
        type = type.to_sym if type.respond_to?(:to_sym)
        loaders[type] || @fallback
      end

      def []=(type, loader_class)
        type = type.to_sym if type.respond_to?(:to_sym)
        loaders[type] = loader_class
      end

      attr_writer :fallback, :loaders
      alias fallback fallback=

      private

      def loaders
        @loaders ||= BUILTIN_LOADERS.each_with_object({}) do |pair, result|
          type, name = pair
          result[type] = const_get(name) if const_defined?(name)
        end
      end
    end
  end
end
