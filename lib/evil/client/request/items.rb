class Evil::Client::Request
  # Converts nested hash to array of items (key, value, file?), ordered by keys.
  #
  # This is a base class for Body and Query. It allows body and query to
  # be compared to other bodies and hashes
  #
  # @example
  #   items = Items.new foo: { "бар" => ["[]", File.new("текст.doc"), baz: nil }
  #
  #   items[0].key   # => "foo[baz]"
  #   items[0].value # => nil
  #   items[0].file? # => false
  #
  #   items[1].key   # => "foo[%D0%B1%D0%B0%D1%80][]"
  #   items[1].value # => "%5B%5D"
  #   items[1].file? # => false
  #
  #   items[2].key   # => "foo[%D0%B1%D0%B0%D1%80][]"
  #   items[2].value # => #<File...>
  #   items[2].file? # => true
  #
  # @api private
  # @abstract
  #
  class Items
    include Enumerable

    # @!attribute [r] source
    #
    # @return [Hash] a source hash for items
    #
    attr_reader :source

    # Initializes the array from hash describing request body or query
    #
    # @param [Hash] source
    #
    def initialize(source = {})
      @source = source
      @items  = flatten(source).sort_by(&:key)
    end

    # Returns new list of items, whose source merges given hash
    #
    # @param [Hash] hash Data to be added to items
    #
    # @return [Evil::Client::Request::Items]
    #
    def merge(hash)
      self.class.new source.merge(hash)
    end

    # Iterates by items
    #
    # @return [Enumerator]
    #
    # @yieldparam [Evil::Client::Request::Items::Item]
    #
    def each
      @items.each { |item| yield(item) }
    end

    # Returns keys following Rails convention
    #
    # @return [Array<String>]
    #
    def keys
      map(&:key)
    end

    # Returns value by key of flattened hash
    #
    # @param [#to_s] key
    #
    # @return [Object]
    #
    def [](key)
      item = detect { |item| item.key == key.to_s }
      item && item.value
    end

    # Checks whether items contains files
    #
    # @return [Boolean]
    #
    def multipart?
      any?(&:file?)
    end

    # Checks whether items is equal to another list of items, or hash
    #
    # @param [Object] other
    #
    # @return [Boolean]
    #
    def ==(other)
      to_a == flatten(other).to_a
    end

    # Checks whether items contains another list of items, or hash
    #
    # @param [Object] other
    #
    # @return [Boolean]
    #
    def include?(other)
      (flatten(other).to_a - to_a).empty?
    end

    # Human-readable representation of items
    #
    # @return [String]
    #
    def inspect
      source.inspect
    end

    private

    def flatten(data, keys = [])
      case data
      when Items
        data.to_a
      when Hash
        data.map { |key, val| flatten(val, keys + [key]) }.flatten
      when Array
        data.map { |val| flatten(val, keys + [nil]) }.flatten
      else
        Item.new(data, keys)
      end
    end
  end
end
