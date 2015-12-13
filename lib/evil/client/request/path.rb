class Evil::Client::Request
  # Utility to build a final query of a prepared request
  #
  # @api private
  #
  class Path < Base
    # Returns the relative path with query
    #
    # @return [String]
    #
    def build
      [request.path, query].compact.join("?")
    end

    private

    def query
      Items.new(request.query).url_encoded
    end
  end
end
