# Release Notes

## v0.6.0 – 2018-05-30

### Major changes

  * Updated to Ruby ~> 2.3
  * Added refinements module for `to_key_*` conversions in core classes
  * `KeyTree::Tree` rewritten from scratch, to use a refinements
    to an internal `Hash` structure instead of subclassing `Hash`

### New methods

  * `KeyTree::Forest#key_paths`
  * `KeyTree::Forest#to_key_forest`
  * `KeyTree::Forest#to_key_wood`
  * `KeyTree::Path#===`
  * `KeyTree::Path#to_key_path`
  * `KeyTree::Tree#delete(key_path)`
  * `KeyTree::Tree#delete!(key_path)`
  * `KeyTree::Tree#store(key_path, new_value)`
  * `KeyTree::Tree#store!(key_path, new_value)`
  * `KeyTree::Tree#to_key_tree`
  * `KeyTree::Tree#to_key_wood`

  * Using `KeyTree::Refinements`
    * `Array#to_key_forest`
    * `Array#to_key_path`
    * `Array#to_key_wood`
    * `Hash#to_key_tree`
    * `Hash#to_key_wood`
    * `String#to_key_path`
    * `Symbol#to_key_path`

  * Using `KeyTree::Refine::DeepHash`
    * `Hash#deep`
    * `Hash#deep_delete(key_path)`
    * `Hash#deep_fetch(key_path, default, &default_proc)`
    * `Hash#deep_merge(other)`
    * `Hash#deep_merge!(other)`
    * `Hash#deep_store(key_path, new_value)`
    * `Hash#deep_transform_keys(&block)`
    * `Hash#deep_transform_keys!(&block)`

### Removed methods

  * `KeyTree::Tree` no longer inherits `Hash`, but most of the
    inherited methods didn't work properly anyway

## v0.5.3 – 2018-05-25

### Bug fixes

#### Fix forest default values
Previous release broke default value propagation for forests.

  * c0eccde4 Update forest specs vs default values
  * 35367fd1 Consider Tree default values for Forest#[]
  * 7e10dda5 Add method to find trees with default values
  * 57a320ac Revert "Use proper method to retreive values from trees"
  * 8173775d Make tree_with_key methods private

## v0.5.2 – 2018-05-19

### Bug fixes

#### Conform to Hash#fetch API
`Tree#fetch` confused its block argument with `#default_proc`, but they
have different arguments, so that didn't work out well.

  * 0bd0a6e8 Use proper method to retreive values from trees
  * 14128a6a Conform to Hash#fetch API

## v0.5.1 – 2018-05-19

### New methods

  * `KeyTree::Tree#default_key?(key)`
  * `KeyTree::Tree#format(fmtstr)`
  * `KeyTree::Tree#to_h(string_keys: false)`
  * `KeyTree::Tree#to_json`
  * `KeyTree::Tree#to_yaml`

### Bug fixes

#### Make forests aware of default values in trees

Ensure that forests pick up default values from a tree.

  * ebd1cb06 Return trees and forests untouched
  * 3451a430 Propagate default_proc in fetch
  * e121a4c4 Consider trees to have a key if #default_key?
  * 50bc56ec Detect if a default_proc yields a key value

### New features

#### Key tree content exporters

Support for exporting the contents of a key tree to Hash, JSON, and YAML.
Also includes a convenience string formatter, that fills format strings
with values from a `Tree`.

  * 9b5f05f0 Make exported hash key format selectable
  * e3434d7e Add custom format method
  * fa6a9b16 Serialize the contents of a tree to json or yaml
  * 3fc6466b Convert a tree back into nested hashes
  * e5aecd8b Split symbols into key paths

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
