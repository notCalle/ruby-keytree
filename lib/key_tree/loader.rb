module KeyTree
  # Module to manage key tree loaders
  module Loader
    BUILTIN_LOADERS = {
      json: 'JSON',
      yaml: 'YAML', yml: 'YAML'
    }.freeze

    def self.[](type)
      type = type.to_sym if type.respond_to?(:to_sym)
      loaders[type]
    end

    def self.[]=(type, loader_class)
      type = type.to_sym if type.respond_to?(:to_sym)
      loaders[type] = loader_class
    end

    private_class_method

    def self.loaders
      @loaders ||= BUILTIN_LOADERS.each_with_object({}) do |pair, result|
        type, name = pair
        result[type] = const_get(name) if const_defined?(name)
      end
    end
  end
end
