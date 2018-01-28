require 'key_tree/version'
require 'key_tree/tree'
require 'key_tree/forest'

# Manage a tree of keys
#
# Example:
#   kt=KeyTree[a: 1, b: { c: 2 }]
#   kt["a"]
#   -> 1
#   kt["b.c"]
#   -> 2
#
module KeyTree
  def self.[](contents = {})
    case contents
    when Hash
      KeyTree::Tree[contents]
    when Array
      KeyTree::Forest[*contents]
    else
      raise ArgumentError, "can't load #{contents.class} into a KeyTree"
    end
  end

  # Load a KeyTree from some external serialization
  #
  # load +type+: +serialization+
  #
  # +type+ is upcased to form a class name that should provide a
  # +.load+ class method (like YAML or JSON does).
  #
  # Example:
  #   load(yaml: "---\na: 1\n")
  # => {"a" => 1}
  #
  def self.load(typed_serialization = {})
    unless typed_serialization.size == 1
      raise ArgumentError, "pick one: #{typed_serialization.keys}"
    end

    type, serialization = typed_serialization.flatten

    loader = get_loader(type)
    self[loader.load(serialization)].with_meta_data do |meta_data|
      meta_data << { load: { type: type,
                             loader: loader } }
    end
  end
  end

  private_class_method

  # Get a class for loading external serialization for +type+
  # +require+s the class provider if necessary.
  #
  def self.get_loader(type)
    Class.const_get(type.upcase)
  rescue NameError
    require type.to_s
    retry
  end
end
