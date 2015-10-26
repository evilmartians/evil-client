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
  # All methods without bang are treated as parts of a request path, relative
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
  # and deserialize them to hash-like structures (+Hashie::Mash+).
  #
  # @see https://github.com/intridea/hashie 'hashie' gem for +Mash+ description
  #
  #    response = client.users(1).sms.post! phone: "7101234567", text: "Hello!"
  #
  #    response.class # => Hashie::Mash
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
  #      error.status   # => 400
  #      error.response # => returns the raw response from server,
  #                     #    not serialized to +Mash+
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

    # Initializes the client for remote API
    #
    # @param [Evil::Client::API] api
    #
    def initialize(api)
      @api  = api
      @path = Path
    end

    # Returns full URI that corresponds to the current path
    #
    # @return [String]
    #
    def uri!
      @api.uri path!
    end

    private

    def initialize(api)
      @api  = api
      @path = Path
    end

    def path!
      @path.finalize!
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
