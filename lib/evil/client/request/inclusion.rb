class Evil::Client::Request
  # Allows to check inclusion of one request into another
  #
  # A request includes another one if it has the same type and path,
  # and includes query, body and headers from the included request.
  #
  module Inclusion
    # Checks whether current request includes another object
    #
    # @param [Object] other The object to compare to
    #
    # @return [Boolean]
    #
    def include?(other)
      other.is_a?(self.class) &&
        path == other.path &&
        type == other.type &&
        nested?(body, other.body) &&
        nested?(query, other.query) &&
        nested?(headers, other.headers)
    end

    private

    def nested?(one, other)
      (Items.new(other).pairs - Items.new(one).pairs).empty?
    end

    def stringify_keys(data)
      case data
      when Hash
        data.inject({}) do |hash, (key, value)|
          hash.merge(key.to_s => stringify_keys(value))
        end
      when Array
        data.map { |item| stringify_keys(item) }
      else
        data
      end
    end
  end
end
