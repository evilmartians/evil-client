class Evil::Client
  # Data structure describing a request to remote server
  #
  # Knows how to prepare request from relative path and some data.
  #
  # Initialized by request type, uri and hash of data:
  #
  #     request = Request.new("get", "http://localhost/users/1/sms", text: "Hi")
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

    # @!method initialize(type, uri, data)
    # Initializes request by type, uri and data
    #
    # @param [Symbol] type
    #   The type of the request (+:get+, +:post+, +:patch+, +:delete+)
    # @param [String] uri
    #   The full URI of the request
    # @param [Hash] data
    #   The data to be send to the API
    # @option data [String] :request_id
    #   Optional request id (when used outside of Rails)
    #
    def initialize(type, uri, request_id: nil, **data)
      @type = type.to_s
      @uri = uri || fail(PathError, @path)
      @request_id = request_id || self.class.default_id || fail(RequestIDError)
      @data = data
    end

    # @!attribute [r] type
    #
    # @return [String] Type of current request
    #
    attr_reader :type

    # @!attribute [r] uri
    #
    # @return [String] The full URI of the request
    #
    attr_reader :uri

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
