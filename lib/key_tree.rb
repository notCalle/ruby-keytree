require 'key_tree/forest'
require 'key_tree/loader'
require 'key_tree/refinements'
require 'key_tree/tree'
require 'key_tree/version'

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
  using Refinements

  def self.[](contents = {})
    contents.to_key_wood
  end

  # Load a KeyTree from some external serialization
  #
  # load +type+: +serialization+
  # load +key_prefix+, +type+: +serialization+
  #
  # +type+ is upcased to form a class name that should provide a
  # +.load+ class method (like YAML or JSON does).
  #
  # If a +key_prefix+ is given, it will be prepended to the loaded data.
  #
  # Examples:
  #   load(:yaml, "---\na: 1\n")
  # => {"a" => 1}
  #
  #   load(:yaml, "---\nb: 2\n", prefix: 'a')
  # => {"a.b" => 2}
  #
  def self.load(type, serialization, prefix: nil)
    type = type.to_sym unless type.nil?
    loader = Loader[type]
    contents = loader.load(serialization)
    contents = { prefix => contents } unless prefix.nil?

    contents.to_key_wood.with_meta_data do |meta_data|
      meta_data << { load: { type: type, loader: loader } }
      meta_data << { load: { prefix: prefix } } unless prefix.nil?
    end
  end

  # Open an external file and load contents into a KeyTree
  # When the file basename begins with 'prefix@', the prefix
  # is prepended to all keys in the filee.
  def self.open(file_name)
    type = File.extname(file_name)[/[^.]+/]
    prefix = File.basename(file_name)[/(.+)@/, 1]

    keytree = File.open(file_name, mode: 'rb:utf-8') do |file|
      load_from_file(file, type, prefix)
    end

    return keytree unless block_given?
    yield(keytree)
  end

  # Open all files in a directory and load their contents into
  # a Forest of Trees, optionally following symlinks, and recursing.
  def self.open_all(dir_name, follow_links: false, recurse: false)
    Dir.children(dir_name).reduce(KeyTree::Forest.new) do |result, file|
      path = File.join(dir_name, file)
      next result if File.symlink?(path) && !follow_links
      stat = File.stat(path)
      # rubocop:disable Security/Open
      next result << open(path) if stat.file?
      # rubocop:enable Security/Open
      next result unless recurse && stat.directory?
      result << open_all(path, follow_links: follow_links, recurse: true)
    end
  end

  private_class_method

  def self.load_from_file(file, type, prefix)
    load(type, file.read, prefix: prefix).with_meta_data do |meta_data|
      file_path = file.path
      meta_data << { file: { path: file_path,
                             name: File.basename(file_path),
                             dir: File.dirname(file_path) } }
    end
  end
end
