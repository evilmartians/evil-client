class Evil::Client::Request
  # Represents a request query as an array of items following Rails convention
  #
  # @api public
  #
  class Query < Items
    # Returns a final string of request query
    #
    # @return [String]
    #
    def final
      map(&:to_s).join("&") if any?
    end
  end
end
