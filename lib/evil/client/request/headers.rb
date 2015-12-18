class Evil::Client::Request
  # Represents request headers as a plain stringified hash
  #
  # All specific knowledge about headers is contained here
  #
  # @api private
  #
  class Headers < Items
    # Returns the final hash representing headers of the request
    #
    # @param [Request] request
    #
    # @return [Hash]
    #
    def final(request)
      @request = request
      response_type_headers
        .merge(content_type_headers)
        .merge(request_id_headers)
        .merge(self)
    end

    # Returns headers as a plain hash
    #
    # @return [Hash]
    #
    def to_hash
      inject({}) { |hash, item| hash.merge(item.key => item.value) }
    end

    private

    def multipart?
      @request.body.multipart?
    end

    def request_id
      RequestID.value
    end

    def content_type_headers
      multipart? ? multipart_headers : form_url_headers
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
