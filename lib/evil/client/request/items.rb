class Evil::Client::Request
  # Converts nested hash, which represents either a body or a query,
  # to ordered array of items with methods:
  #
  # * +#key+   - flattened escaped key
  # * +#value+ - either escaped string, or file
  # * +#file?+ - whether [#value] is a file
  #
  # Items are ordered by keys
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
    def initialize(source)
      @source = source
    end

    # Iterates by items
    #
    # @return [Enumerator]
    #
    # @yieldparam [Evil::Client::Request::Items::Item]
    #
    def each
      return to_enum unless block_given?
      @items ||= pre_flatten(source).flatten.sort_by(&:key)
      @items.each { |item| yield(item) }
    end

    # Checks whether source contains files
    #
    # @return [Boolean]
    #
    def multipart?
      any?(&:file?)
    end

    # Represents items as pairs of [key, value]
    #
    # @return [Array<String, Object>]
    #
    def pairs
      map { |item| [item.key, item.value] }
    end

    private

    def pre_flatten(data, *keys)
      case data
      when Hash
        data.map { |key, val| pre_flatten(val, *keys, key) }
      when Array
        data.map { |val| pre_flatten(val, *keys, nil) }
      else
        Item.new(data, *keys)
      end
    end

    # Describes a single item
    #
    # @api private
    #
    class Item
      # Initializes a value from raw unescaped value and array of its keys
      #
      # @param [Object] raw_value
      # @param [Array<#to_s>] keys
      #
      def initialize(raw_value, *keys)
        @raw_value = raw_value
        @keys      = keys.map(&:to_s).map(&CGI.method(:escape))
      end

      # The nested escaped key for the item
      #
      # @return [String]
      #
      def key
        @key ||= begin
          list = [@keys.first] + @keys[1..-1].to_a.map { |k| "[#{k}]" }
          list.join
        end
      end

      # The value stringified and escaped when necessary
      #
      # @return [String, File, nil]
      #
      def value
        @value ||=
          if @raw_value.nil? || file?
            @raw_value
          else
            CGI.escape(@raw_value.to_s)
          end
      end

      # The predicate to check whether [#value] is a file
      #
      # @return [Boolean]
      #
      def file?
        if @file.nil?
          @file = @raw_value.respond_to?(:read) && @raw_value.respond_to?(:path)
        end
        @file
      end
    end
  end
end
