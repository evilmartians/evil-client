class Evil::Client::Request
  # Utility to build final headers of a prepared request
  #
  # @api private
  #
  class Headers
    # Instantiates and calls the utility to return headers
    #
    # @param [Evil::Client::Request] request
    #
    # @return [Hash]
    #
    def self.call(request)
      new(request).call
    end

    # @!attribute [r] request
    #
    # @return [Evil::Client::Request] the request whose headers are provided
    #
    attr_reader :request

    # Initializes the utility
    #
    # @param [Evil::Client::Request] request
    #
    def initialize(request)
      @request = request
    end

    # Returns the resulting headers
    #
    # @return [Hash]
    #
    def call
      hash = common_headers
      hash.update(default_headers)
      hash.update(request_id_headers) if request_id
      hash.update(request.headers) # adds custom headers
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
      { "X-Request-Id" => request_id }
    end

    def form_url_headers
      { "Content-Type" => "www-url-form-encoded; charset=utf-8" }
    end

    def multipart_headers
      { "Content-Type" => "multipart/form-data; charset=utf-8" }
    end
  end
end
