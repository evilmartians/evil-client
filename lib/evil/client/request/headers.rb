class Evil::Client::Request
  # Utility to build final headers of a prepared request
  #
  # @api private
  #
  class Headers < Base
    # Returns the resulting headers
    #
    # @return [Hash]
    #
    def build
      response_type_headers
        .update(content_type_headers)
        .update(request_id_headers)
        .update(request.headers) # customized by user
        .inject({}) { |h, (key, value)| h.merge(key.to_s => value.to_s) }
    end

    private

    def request_id
      @request_id ||= RequestID.value
    end

    def content_type_headers
      request.multipart? ? multipart_headers : form_url_headers
    end

    def response_type_headers
      { "Accept" => "application/json" }
    end

    def request_id_headers
      request_id ? { "X-Request-Id" => request_id } : {}
    end

    def form_url_headers
      { "Content-Type" => "www-url-form-encoded; charset=utf-8" }
    end

    def multipart_headers
      { "Content-Type" => "multipart/form-data; charset=utf-8" }
    end
  end
end
