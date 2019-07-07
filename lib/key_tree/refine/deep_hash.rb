# frozen_string_literal: true

require_relative '../path'

module KeyTree
  module Refine
    # Refinements to Hash for deep_ methods, for traversing nested structures
    module DeepHash
      refine Hash do
        # Return a deep enumerator for all (+key_path+, +value+) pairs in a
        # nested hash structure.
        #
        # :call-seq:
        #   deep => Enumerator
        def deep
          Enumerator.new do |yielder|
            deep_enumerator(yielder)
          end
        end

        # Fetch a leaf value from a nested hash structure
        #
        # :call-seq:
        #   deep_fetch(key_path) => value
        #   deep_fetch(key_path, default) => value || default
        #   deep_fetch(key_path) { |key_path| block } => value || block
        def deep_fetch(key_path, *default)
          catch do |ball|
            result = key_path.reduce(self) do |hash, key|
              throw ball unless hash.is_a?(Hash)
              hash.fetch(key) { throw ball }
            end
            return result unless result.is_a?(Hash)
          end
          return yield(key_path) if block_given?
          return default.first unless default.empty?

          raise KeyError, %(key path invalid: "#{key_path}")
        end

        # Store a new value in a nested hash structure, expanding it
        # if necessary.
        #
        # :call-seq:
        #   deep_store(key_path, new_value) => new_value
        #
        # Raises KeyError if a prefix of the +key_path+ has a value.
        def deep_store(key_path, new_value)
          *prefix_path, last_key = key_path
          result = prefix_path.reduce(self) do |hash, key|
            result = hash.fetch(key) { hash[key] = {} }
            next result if result.is_a?(Hash)

            raise KeyError, %(prefix has value: "#{key_path}")
          end
          result[last_key] = new_value
        end

        # Delete a leaf value in a nested hash structure
        #
        # :call-seq:
        #   deep_delete(key_path)
        #
        # Raises KeyError if a prefix of the +key_path+ has a value.
        def deep_delete(key_path)
          *prefix_path, last_key = key_path
          result = prefix_path.reduce(self) do |hash, key|
            result = hash.fetch(key, nil)
            next result if result.is_a?(Hash)

            raise KeyError, %(prefix has value: "#{key_path}")
          end
          result.delete(last_key)
        end

        # Deeply merge nested hash structures
        #
        # :call-seq:
        #   deep_merge!(other) => self
        #   deep_merge!(other) { |key_path, lhs, rhs| } => self
        def deep_merge!(other, prefix = [], &block)
          merge!(other) do |key, lhs, rhs|
            key_path = prefix + [key]
            both_are_hashes = lhs.is_a?(Hash) && rhs.is_a?(Hash)
            next lhs.deep_merge!(rhs, key_path, &block) if both_are_hashes
            next yield(key_path, lhs, rhs) unless block.nil?

            rhs
          end
        end

        # Deeply merge nested hash structures
        #
        # :call-seq:
        #   deep_merge(other) => self
        #   deep_merge(other) { |key_path, lhs, rhs| } => self
        def deep_merge(other, prefix = [], &block)
          merge(other) do |key, lhs, rhs|
            key_path = prefix + [key]
            both_are_hashes = lhs.is_a?(Hash) && rhs.is_a?(Hash)
            next lhs.deep_merge(rhs, key_path, &block) if both_are_hashes
            next yield(key_path, lhs, rhs) unless block.nil?

            rhs
          end
        end

        # Transform keys in a nested hash structure
        #
        # :call-seq:
        #   deep_transform_keys { |key| block }
        def deep_transform_keys(&block)
          result = transform_keys(&block)
          result.transform_values! do |value|
            next value unless value.is_a?(Hash)

            value.deep_transform_keys(&block)
          end
        end

        # Transform keys in a nested hash structure
        #
        # :call-seq:
        #   deep_transform_keys! { |key| block }
        def deep_transform_keys!(&block)
          result = transform_keys!(&block)
          result.transform_values! do |value|
            next value unless value.is_a?(Hash)

            value.deep_transform_keys!(&block)
          end
        end

        # Comvert any keys containing a +.+ in a hash structure
        # to nested hashes.
        #
        # :call-seq:
        #   deep_key_pathify => Hash
        def deep_key_pathify
          each_with_object({}) do |(key, value), result|
            key_path = Path[key]
            value = value.deep_key_pathify if value.is_a?(Hash)
            result.deep_store(key_path, value)
          end
        end

        def deep_enumerator(yielder, prefix = [])
          each do |key, value|
            key_path = prefix + [key]
            yielder << [key_path, value]
            value.deep_enumerator(yielder, key_path) if value.is_a?(Hash)
          end
        end
      end
    end
  end
end
