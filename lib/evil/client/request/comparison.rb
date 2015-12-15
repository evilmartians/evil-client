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
      like?(other) &&
        nested?(body, other.body) &&
        nested?(query, other.query) &&
        nested?(headers, other.headers)
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
      like?(other) &&
        same?(body, other.body) &&
        same?(query, other.query) &&
        same?(headers, other.headers)
    end

    private

    def like?(other)
      other.is_a?(self.class) &&
        protocol == other.protocol &&
        host == other.host &&
        path == other.path &&
        port == other.port &&
        method == other.method
    end

    def nested?(one, other)
      (Items.new(other).pairs - Items.new(one).pairs).empty?
    end

    def same?(one, other)
      Items.new(other).pairs == Items.new(one).pairs
    end
  end
end
