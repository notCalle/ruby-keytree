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
end
