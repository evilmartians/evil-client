require "json"

class Evil::Client
  # Structure describing a prepared request to API
  #
  # Knows how to prepare request from relative path and some data.
  # Eventually it will also validate requests against the API specification.
  #
  # Initialized by relative address, request type and parameters,
  # with reference to API specification:
  #
  #     api     = API.new base_url: "http://my_api.com/v1"
  #     request = Request.new(api, "users/1/sms", :patch, text: "Hello")
  #
  #     request.uri
  #     # => "http://my_api.com/v1/users/1/sms"
  #     request.params
  #     # => {
  #     #      header: { "X-Request-Id" => "foobarbaz" },
  #     #      body: { text: "Hello", _method: "patch" }
  #     #    }
  #     request.valid?
  #     # => true
  #
  # @api private
  #
  class Request

    include Errors

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

    # @!attribute [r] data
    #
    # @return [Hash] data to be sent to API
    #
    attr_reader :data

    # Initializes request by type, path and adapter with reference to api
    # and logger
    #
    # @param [Evil::Client::API] api
    #   The API to which the request should be sent
    # @param [Symbol] type
    #   The type of the request (+:get+, +:post+, +:patch+, +:delete+)
    # @param [String] path
    #   The relative path to the API's base_url
    # @param [Hash] data
    #   The data to be send to the API
    #
    def initialize(api, type, path, **data)
      @api  = api
      @type = type.to_s
      @path = path
      @data = data
    end

    # Adapter used by [#api] to send the request
    #
    # @return [JSONClient]
    #
    def adapter
      @adapter ||= api.adapter
    end

    # The full URI of the request
    #
    # @return [String]
    #
    def uri
      @uri ||= api.uri(path)
    end

    # Request parameters
    #
    # @return [Hash]
    #
    def params
      @params ||= begin
        key = (type.eql? "get") ? :query : :body
        { key => data.merge(send_method) }.merge(headers)
      end
    end

    # Validates the request
    #
    # @return [self] itself
    #
    # @raise [Evil::Client::Errors::PathError]
    #   when [#path] doesn't satisfies API
    #
    def validate
      fail(PathError, path) unless uri
      self
    end

    # Array representation of the request to be sent to connection
    #
    # @return [Array]
    # 
    def to_a
      [type, uri, params]
    end

    private

    def headers
      { header: { "X-Request-Id" => api.request_id } }
    end

    def send_method
      %w(get post).include?(type) ? {} : { _method: type }
    end
  end
end
