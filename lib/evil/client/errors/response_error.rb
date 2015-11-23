module Evil::Client::Errors
  # Exception for the case remote API responds with error (status 4** or 5**)
  #
  # @api public
  #
  class ResponseError < RuntimeError
    # Initializes exception for error response from server
    #
    # @param [Evil::Client::Request] request
    # @param [HTTP::Message] raw_response
    #
    def initialize(request, raw_response)
      @request  = request
      @response = raw_response

      super "#{request.type.upcase} request to #{request.path}" \
            " with params #{request.params}" \
            " has responded with error (status #{response.status})."
    end

    # @!attribute [r] request
    #
    # @return [Evil::Client::Request] The request that causes the error
    #
    attr_reader :request

    # @!attribute [r] request
    #
    # @return [HTTP::Message] The raw response from server
    #
    attr_reader :response

    # The status of the response
    #
    # @return [Integer]
    #
    def status
      @status ||= response.status
    end

    # Deserialized content of the response
    #
    # @return [Hashie::Mash]
    #
    def content
      @content ||= response.content
    end
  end
end
