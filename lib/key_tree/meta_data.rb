module KeyTree
  #
  # Mixin for adding a meta_data key tree
  #
  module MetaData
    #
    # Get the meta_data for an object
    #
    def meta_data
      @meta_data ||= KeyTree::Tree.new
    end

    # Execute a block with meta data, returning self
    #
    def with_meta_data
      yield(meta_data)
      self
    end
  end
end
