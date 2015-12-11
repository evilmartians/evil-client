class Evil::Client::Request
  # Utility to build a final query of a prepared request
  #
  # @api private
  #
  class Path < Base
    # Returns the resulting path with query
    #
    # @return [String]
    #
    def build
      [path, query].compact.join("?")
    end

    private

    def path
      request.path
    end

    def query
      return unless items.any?
      items
        .map { |item| item.value ? "#{item.key}=#{item.value}" : item.key }
        .join("&")
    end

    def items
      @items ||= Items.new(request.query)
    end
  end
end
