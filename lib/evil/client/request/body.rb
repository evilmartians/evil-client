class Evil::Client::Request
  # Utility to build a final body of a prepared request
  #
  # @api private
  #
  class Body < Base
    # Returns the resulting body
    #
    # @return [String]
    #
    def build
      return if request.type == "get"
      return to_multipart if request.multipart?
      to_form_url
    end

    private

    def to_multipart
      Multipart.build(request)
    end

    def to_form_url
      URI.escape(plain_body)
    end

    def plain_body
      request.flat_body.map { |item| item[0..1].join("=") }.join("&")
    end
  end
end
