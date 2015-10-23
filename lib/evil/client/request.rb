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
  class Request

    attr_reader :api
    attr_reader :type
    attr_reader :uri
    attr_reader :params
    attr_reader :adapter

    # Initializes request by type, path and adapter
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
      @uri    = api.uri(path)
      @params = params
      validate
      @adapter = JSONClient.new base_url: @api.base_url
    end

    # Checks and calls the request, handles and returns the response
    #
    # @return [Hashie::Mash] The response body converted to extended hash
    #
    def call(&block)
      handle_response __send__(type), &block
    end

    private

    def validate
      fail(PathError, path) unless uri
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

    def handle(response)
      return JSON(response.body) if response.status < 400
      block_given? ? yield(response) : fail(ResponseError, response)
    end
  end
end
