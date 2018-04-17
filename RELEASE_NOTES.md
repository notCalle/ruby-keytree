# Release Notes

## v0.5.0 – 2018-04-17

### Changed methods

  * `KeyTree.load(type, serialization, prefix: nil)`
  * `KeyTree::Forest#[key] { |key, original, incoming| }`
  * `KeyTree::Forest#fetch(key) { |key, original, incoming| }`
  * `KeyTree::Forest#flatten { |key, original, incoming| }`
  * `KeyTree::Tree#merge { |key, original, incoming| }`
  * `KeyTree::Tree#merge! { |key, original, incoming| }`

### New methods

  * `KeyTree::Loader.fallback(loader)`

### New features

#### Merge value selection
Improve merge related methods in `KeyTree::Tree`, and `KeyTree::Forest`
to take a `Hash#merge` style block argument, to allow control of the result when a key i present on both sides of a merge operation.

  * 083b25c Add merge value selector to Forest#[]
  * e813e55 Add merge value selection to Forest#fetch
  * 581bc82 Add method to get list of trees with key
  * 0f66f03 Pass merge value selector via Forest#flatten
  * df9b80e Pass any merge selection block to super

#### Key prefix for file loading
When a key file has a name like `prefix@name.ext`, the `prefix` part will be prepended to all keys loaded from the file.

  * fbe333a Changed call syntax for KeyTree.load
  * 595902c Load keytree with prefix from files with @ in name
  * d23a7e1 Allow prepending a prefix when loading keys

#### Fallback for KeyTree loaders
Allow a fallback class for handling loading of file types where no loader is specified, e.g. to ignore all files with unrecognized extension for `KeyTree.load_all`.

  * a9d096c Add tree loader fallback

### Bug fixes

#### Proper breadth first flattening

  * ff327f2 Use tree enumarator for Forest#key? and #prefix?
  * 74fa15d Rewrite Forest#[]
  * 177de08 Use tree enumerator in Forest#[]
  * d161fe1 Use tree enumerator in Forest#flatten
  * b0c94df Add breadth-first enumerator for trees
  * 3468f28 Remove forest vs tree sorting nonsense
