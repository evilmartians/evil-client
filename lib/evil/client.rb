require "jsonclient"

# Namespace for evilmartians projects
module Evil
  # The client prepares URI with method chaining, sends requests to remote API,
  # validates and returns server responses.
  #
  # @api public
  #
  class Client

    require_relative "client/errors"
    require_relative "client/api"
    require_relative "client/request_id"
    require_relative "client/request"
    require_relative "client/response"
    require_relative "client/adapter"
    require_relative "client/rails" if defined? ::Rails

    # There will be several ways to prepare api for initialization
    # For every way we define a custom constructor, like [.with]
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
    # @param [Evil::Client::API] api
    #
    def initialize(api)
      @api = api
      @request = Request.new(api.base_url)
    end

    # Adds part to the URI
    #
    # @param (see Evil::Client::Request#with_path)
    #
    # @return [Evil::Client] updated client
    #
    def path(*parts)
      request = @request.with_path(*parts)
      update { @request = request }
    end

    # Adds parameters to the query
    #
    # @param (see Evil::Client::Request#with_query)
    #
    # @return [Evil::Client] updated client
    #
    def query(query)
      request = @request.with_query(query)
      update { @request = request }
    end

    # Adds headers
    #
    # @param (see Evil::Client::Request#with_headers)
    #
    # @return [Evil::Client] updated client
    #
    def headers(headers)
      request = @request.with_headers(headers)
      update { @request = request }
    end

    # Returns full URI that corresponds to the current path
    #
    # @return [String]
    #
    def uri
      @request.path
    end

    # Calls a request with type, data, and error handler
    #
    # @param [String] type
    # @param [Hash] data
    # @param [Proc] error_hanlder
    #
    # @return (see Evil::Client::Adapter#call)
    # @yieldparam (see Evil::Client::Adapter#call)
    #
    def call(type, **data, &error_handler)
      with    = (type == "get") ? :with_query : :with_body
      request = @request.send(with, data).with_type(type)
      
      adapter.call(request, &error_handler)
    end

    # Calls a request and returns false in case of error response
    #
    # @param (see #call)
    #
    # @return (see #call)
    # @return [false] in case of error response
    #
    def try_call(type, **data)
      call(type, **data) { false }
    end

    private

    CALL_METHOD = /^(try_)?(get|post|patch|put|delete)$/.freeze

    def adapter
      @adapter ||= Adapter.for_api(@api)
    end

    def update(&block)
      dup.tap { |client| client.instance_eval(&block) }
    end

    def method_missing(name, *args, &block)
      return super unless respond_to? name
      _, try, type = name.to_s.match(CALL_METHOD).to_a

      send("#{try}call", type, *args, &block)
    end

    def respond_to_missing?(name, *)
      name[CALL_METHOD]
    end
  end
end
