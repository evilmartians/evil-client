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
    def uri!
      @request.path
    end

    private

    CALL_METHOD = /^[a-z]+\!$/.freeze
    SAFE_METHOD = /^try_[a-z]+\!$/.freeze

    def call(type, **data, &error_handler)
      str_type = type.to_s
      if str_type == "get"
        request = @request.with_query(data)
      else
        request = @request.with_body(data)
      end
      adapter.call request.with_type(str_type), &error_handler
    end

    def adapter
      @adapter ||= Adapter.for_api(@api)
    end

    def update(&block)
      dup.tap { |client| client.instance_eval(&block) }
    end

    def method_missing(name, *args, &block)
      if name[CALL_METHOD]
        call(name[0..-2].to_sym, *args, &block)
      elsif name[SAFE_METHOD]
        call(name[4..-2].to_sym, *args) { false }
      end
    end

    def respond_to_missing?(name, *)
      name[/#{CALL_METHOD}|#{SAFE_METHOD}/]
    end
  end
end
