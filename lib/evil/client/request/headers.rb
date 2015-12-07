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
      common_headers
        .update(default_headers)
        .update(request_id_headers)
        .update(request.headers)
        .inject({}) { |h, (key, value)| h.merge(key.to_s => value.to_s) }
    end

    private

    def request_id
      @request_id ||= RequestID.value
    end

    def default_headers
      return multipart_headers if request.multipart?
      form_url_headers
    end

    def common_headers
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
