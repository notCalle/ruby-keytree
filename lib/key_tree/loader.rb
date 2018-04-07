module KeyTree
  # Module to manage key tree loaders
  module Loader
    BUILTIN_LOADERS = {
      json: 'JSON',
      yaml: 'YAML', yml: 'YAML'
    }.freeze

    def self.[](loader_type)
      @loaders ||= BUILTIN_LOADERS.each_with_object({}) do |pair, result|
        type, name = pair
        result[type] = const_get(name) if const_defined?(name)
      end
      @loaders[loader_type]
    end

    def self.[]=(type, loader_class)
      @loaders[type] = loader_class
    end
  end
end
