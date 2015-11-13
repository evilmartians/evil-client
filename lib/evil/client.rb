require "jsonclient"

module Evil
  # The client prepares URI with method chaining, sends requests to remote API,
  # validates and returns server responses.
  #
  # It is initialized with +base_url+
  #
  #    client = Client.with base_url: "127.0.0.1/v1"
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
  # and deserializes their bodies.
  #
  #    response = client.users(1).sms.post! phone: "7101234567", text: "Hello!"
  #
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
  # In case of successful response, +Hashie::Mash+ structure will be returned
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

    private_class_method :new

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

    # Initializes a client instance with API specification
    #
    # @param [Evil::Client::API]
    #
    def initialize(api)
      @path = Path.new
      @api  = api
    end

    # Adds part to the URI
    #
    # @return [Evil::Client] updated client
    #
    def [](value)
      update! { @path = @path[value] }
    end

    # Returns full URI that corresponds to the current path
    #
    # @return [String]
    #
    def uri!
      @api.uri @path.to_s
    end

    private

    CALL_METHOD = /^[a-z]+\!$/.freeze
    PATH_METHOD = /^\w+$/.freeze

    def call!(type, data, &error_handler)
      request = Request.new(type, uri!, data)
      @adapter ||= Adapter.for_api(api)
      @adapter.call request, &error_handler
    end

    def update!(&block)
      dup.tap { |client| client.instance_eval(&block) }
    end

    def method_missing(name, *args, &block)
      if name[CALL_METHOD]
        call!(name[0..-2].to_sym, *args, &block)
      elsif name[PATH_METHOD]
        self[name]
      end
    end

    def respond_to_missing?(name, *)
      name[PATH_METHOD] || name[CALL_METHOD]
    end
  end
end
