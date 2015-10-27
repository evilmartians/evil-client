require "jsonclient"

module Evil
  # The client prepares URI with method chaining, sends requests to remote API,
  # validates and returns server responses.
  #
  # It is initialized with +base_url+ and optional +request_id+:
  #
  #    client = Client.with base_url: "127.0.0.1/v1", request_id: "s30f@sa#2fep"
  #
  # When the gem is used inside Rails app, the request_id is taken
  # from railtie "evil.client.rails.request_id".
  #
  # All methods without `!` are treated as parts of a request path, relative
  # to +base_url+:
  #
  #    client.users[1].sms
  #
  # Use [#uri!] method to check the full URI:
  #
  #    client.users[1].sms.uri! # => "127.0.0.1/v1/users/1/sms"
  #
  # Methods [#get!], [#post!], [#patch!], [#delete!] prepares and sends
  # synchronous requests to the RESTful API, checks responces,
  # and deserializes them to hash-like [Evil::Client::Response].
  #
  #    response = client.users(1).sms.post! phone: "7101234567", text: "Hello!"
  #
  #    response.class # => Evil::Client::Response
  #    response.id    # => 100
  #    response.phone # => "7101234567"
  #    response.text  # => "Hello!"
  #
  # In case API returns error response (4**, 5**) the exception is raised
  # with error +status+ and +response+ attributes:
  #
  #    begin
  #      client.users[1].sms.post! text: "Hello!"
  #    rescue Evil::Client::Error::ResponseError => error
  #      error.content # => returns the raw message received from server,
  #                    #    (::HTTP::Message)
  #    end
  #
  # Alternatively you can provide the block for handling error responces.
  # In this case the raw error response will be given to the block
  # without raising any exception:
  #
  #    client.users(1).sms.post(phone: "7101234567") do |error_response|
  #      error_response.status
  #    end
  #    # => 400
  #
  # In case of successful response, +Mash+ structure will be returned
  # as were shown above.
  #
  # @api public
  #
  class Client

    require_relative "client/errors"
    require_relative "client/path"
    require_relative "client/api"
    require_relative "client/request"
    require_relative "client/response"
    require_relative "client/adapter"
    require_relative "client/rails" if defined? ::Rails

    # Initializes a client instance with API settings
    #
    # @param [Hash] settings
    # @options settings (see Evil::Client::API#initialize)
    #
    # @return [Evil::Client]
    #
    def self.with(settings)
      api = API.new(settings)
      new api
    end

    private_class_method :new

    # Initializes a client instance with API specification
    #
    # @param [Evil::Client::API]
    #
    def initialize(api)
      @path = Path
      @api  = api
    end

    # Returns full URI that corresponds to the current path
    #
    # @return [String]
    #
    def uri!
      path = @path.finalize!
      @api.uri path
    end

    # Sends GET request to the current [#uri!] with given parameters
    #
    # @param [Hash] params
    #
    # @return [Evil::Client::Response] Deserialized body of the successful response
    #
    # @yield block if the server responded with error (status 4** or 5**)
    # @yieldparam [HTTP::Message] The raw response from the server
    #
    # @see http://www.rubydoc.info/gems/httpclient/HTTP/Message
    #   Docs for HTTP::Message format
    #
    def get!(**data)
      call! :get, data
    end

    # Sends POST request to the current [#uri!] with given parameters
    #
    # @param [Hash] params
    #
    # @return [Evil::Client::Response] Deserialized body of the successful response
    #
    # @yield      (see #get!)
    # @yieldparam (see #get!)
    #
    def post!(**data)
      call! :post, data
    end

    # Sends PATCH request to the current [#uri!] with given parameters
    #
    # @param [Hash] params
    #
    # @return [Evil::Client::Response] Deserialized body of the successful response
    #
    # @yield      (see #get!)
    # @yieldparam (see #get!)
    #
    def patch!(**data)
      call! :patch, data
    end

    # Sends DELETE request to the current [#uri!] with given parameters
    #
    # @param [Hash] params
    #
    # @return [Evil::Client::Response] Deserialized body of the successful response
    #
    # @yield      (see #get!)
    # @yieldparam (see #get!)
    #
    def delete!(**data)
      call! :delete, data
    end

    private

    def call!(type, data)
      request = Request.new(type, uri!, data)
      @adapter ||= Adapter.for_api(api)
      @adapter.call request
    end

    def update!(&block)
      dup.tap { |client| client.instance_eval(&block) }
    end

    def method_missing(name, *args)
      update! { @path = @path.public_send(name, *args) }
    end

    def respond_to_missing?(name, *)
      @path.respond_to?(name)
    end
  end
end
