class Evil::Client::Request
  # Defines methdos `include?` and `==` to compare requests to each other
  #
  module Comparison
    # Checks whether current request includes another object
    #
    # Included request should have the same method and path,
    # and subset of the other requests's body, query and headers.
    #
    # @param [Object] other The object to compare to
    #
    # @return [Boolean]
    #
    def include?(other)
      other.is_a?(self.class) && match?(other.to_h, false)
    end

    # Checks whether current request equals to another object
    #
    # Both requests should have the same method, path, body, query and headers.
    #
    # @param [Object] other The object to compare to
    #
    # @return [Boolean]
    #
    def ==(other)
      other.is_a?(self.class) && match?(other.to_h, true)
    end

    # Checks whether current request matches a hash of attributes
    #
    # @param [Hash] hash
    # @param [Boolean] strict
    #   Whether the comparison should be strict (equality), or not (inclusion)
    #
    # @return [Boolean]
    #
    def match?(hash, strict = true)
      ATTRIBUTES.inject(true) do |result, name|
        result && match_attribute?(name, hash[name], strict)
      end
    end

    private

    def match_attribute?(name, expected, strict = true)
      return true if expected.nil?

      actual = send(name)
      case name
      when :body, :query, :headers
        match_hash?(actual, expected, strict)
      when :path
        match_path?(actual, expected)
      when :method
        match_method?(actual, expected)
      end
    end

    def match_hash?(actual, expected, strict)
      if strict
        Items.new(expected).pairs == Items.new(actual).pairs
      else
        (Items.new(expected).pairs - Items.new(actual).pairs).empty?
      end
    end

    def match_path?(actual, expected)
      !actual[%r{^/?#{expected}$}].nil?
    end

    def match_method?(actual, expected)
      actual == expected.to_s.downcase
    end
  end
end
