class Evil::Client
  # Request to remote API
  #
  # Prepares and sends requests to API, deserializes successful responses
  # to hash-like structures, or raises exceptions in case of errors.
  #
  # Eventually it will also validate requests and responses against
  # the API specification.
  #
  # The request is described by relative address, request type and parameters,
  # with reference to API specification:
  #
  #     api     = API.new base_url: "http://my_api.com/v1"
  #     request = Request.new(api, "users/1/sms", :post, text: "Hello")
  #
  # [#call] the request to send it and receive the body of successful response,
  # that is deserialized to hash-like structure (+Mash+):
  #
  #     result = request.call
  #     result.id # => 1
  #     result.
  #
  # When used without block, [#call] raises an exception in case of error
  # response. Otherwise it sends the raw error response to the block, leaving
  # its handling to the user.
  #
  #    result = request.call do |error_response|
  #      error_response.status
  #    end
  #    # => 403
  #
  # @api private
  #
  class Request

    # @!attribute [r] api
    #
    # @return [Evil::Client::API] API to which request should be sent
    #
    attr_reader :api

    # @!attribute [r] type
    #
    # @return [Symbol] Type of current request
    #
    attr_reader :type

    # @!attribute [r] path
    #
    # @return [String] path relative to API base url
    #
    attr_reader :path

    # @!attribute [r] params
    #
    # @return [Hash] request parameters
    #
    attr_reader :params

    # Initializes request by type, path and adapter with reference to api
    # and logger
    #
    # @param [Evil::Client::API] api
    #   The API to which the request should be sent
    # @param [Symbol] type
    #   The type of the request (+:get+, +:post+, +:patch+, +:delete+)
    # @param [String] path
    #   The relative path to the API's base_url
    # @param [Hash] params
    #   The optional parameters of the request
    #
    def initialize(api, type, path, **params)
      @api    = api
      @type   = type
      @path   = path
      @params = params
    end

    # The full URI of the request
    #
    # @return [String]
    #
    def uri
      @uri ||= api.uri(path) || fail(PathError, path)
    end

    # Checks and calls the request, handles and returns its response
    #
    # @return [Hashie::Mash] The response body converted to extended hash
    #
    def call(&block)
      response = __send__(type)
      return mash(response) if response.status < 400
      block_given? ? yield(response) : fail(ResponseError, response)
    end

    private

    def adapter
      @adapter ||= api.adapter
    end

    def get
      adapter.get_content(uri, query: params, **headers)
    end

    def post
      adapter.post_content(uri, body: params, **headers)
    end

    def patch
      post params.merge(_method: "patch")
    end

    def delete
      post params.merge(_method: "delete")
    end

    def headers
      { header: { "X-Request-Id" => api.request_id } }
    end

    def mash(response)
      body = JSON(response.body)
      Hashie::Mash.new(body)
    end
  end
end
