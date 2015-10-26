require "json"

class Evil::Client
  # Structure describing a request to API
  #
  # Knows how to prepare request from relative path and some data.
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
  #
  # @api public
  #
  class Request

    include Errors

    # @api private
    class << self
      # @!attribute [w] id_provider
      #
      # @return [#value] Storage for API client ID (to be set from Railtie)
      #
      attr_writer :id_provider

      # API request ID given from Railtie
      #
      # @return [String]
      #
      def default_id
        @id_provider && @id_provider.value
      end
    end

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
    # @option data [String] :request_id
    #   Optional request id (when used outside of Rails)
    #
    def initialize(api, type, path, request_id: nil, **data)
      @api = api
      @type = type.to_s
      @path = path
      @request_id = request_id || self.class.default_id || fail(RequestIDError)
      @data = data
    end

    # @!attribute [r] type
    #
    # @return [Symbol] Type of current request
    #
    attr_reader :type

    # The full URI of the request
    #
    # @return [String]
    #
    def uri
      @uri ||= @api.uri(@path) || fail(PathError, @path)
    end

    # Request parameters
    #
    # @return [Hash]
    #
    def params
      @params ||= begin
        key = (type.eql? "get") ? :query : :body
        { key => @data.merge(send_method) }.merge(headers)
      end
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
      { header: { "X-Request-Id" => @request_id } }
    end

    def send_method
      %w(get post).include?(type) ? {} : { _method: type }
    end
  end
end
