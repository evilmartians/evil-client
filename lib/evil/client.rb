require "delegate"
require "hashie/mash"
require "logger"
require "mime-types"
require "pathname"
require "rack"
require "securerandom"
require "tempfile"

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
      clone_with { @request = request }
    end

    # Adds parameters to the query
    #
    # @param (see Evil::Client::Request#with_query)
    #
    # @return [Evil::Client] updated client
    #
    def query(values)
      request = @request.with_query(values)
      clone_with { @request = request }
    end

    # Adds headers
    #
    # @param (see Evil::Client::Request#with_headers)
    #
    # @return [Evil::Client] updated client
    #
    def headers(values)
      request = @request.with_headers(values)
      clone_with { @request = request }
    end

    # Prepares JSON request
    #
    # @return [Evil::Client] updated client
    #
    def in_json
      request = @request.in_json
      clone_with { @request = request }
    end

    # Returns full URI that corresponds to the current path
    #
    # @return [String]
    #
    def uri
      @request.path
    end

    # Calls a GET request safely
    #
    # @param  [Hash] query
    # @return [Hashie::Mash]
    #
    def get(query = {})
      query(query).request :get
    end

    # Calls a GET request unsafely
    #
    # @param  (see #get)
    # @return (see #get)
    # @raise  (see #request!) in case of error response
    #
    def get!(query = {})
      query(query).request! :get
    end

    # Calls a POST request safely
    #
    # @param [Hash] body
    # @return [Hashie::Mash]
    #
    def post(body = {})
      request("post", body)
    end

    # Calls a POST request unsafely (raises in case of error response)
    #
    # @param  (see #post)
    # @return (see #post)
    # @raise  (see #request!) in case of error response
    #
    def post!(body = {})
      request!("post", body)
    end

    # Calls a DELETE request safely
    #
    # @param  (see #post)
    # @return (see #post)
    #
    def patch(body = {})
      request("patch", body)
    end

    # Calls a PATCH request unsafely (raises in case of error response)
    #
    # @param  (see #post!)
    # @return (see #post!)
    # @raise  (see #post!)
    #
    def patch!(body = {})
      request!("patch", body)
    end

    # Calls a PUT request safely
    #
    # @param  (see #post)
    # @return (see #post)
    #
    def put(body = {})
      request("put", body)
    end

    # Calls a PUT request unsafely (raises in case of error response)
    #
    # @param  (see #post!)
    # @return (see #post!)
    # @raise  (see #post!)
    #
    def put!(body = {})
      request!("put", body)
    end

    # Calls a DELETE request safely
    #
    # @param  (see #post)
    # @return (see #post)
    #
    def delete(body = {})
      request("delete", body)
    end

    # Calls a DELETE request unsafely (raises in case of error response)
    #
    # @param  (see #post!)
    # @return (see #post!)
    # @raise  (see #post!)
    #
    def delete!(body = {})
      request!("delete", body)
    end

    # @!method request(type, body)
    # Calls a request with custom method type safely
    #
    # @param  (see #request!)
    # @return (see #request!)
    #
    def request(*args)
      adapter.call prepare_request(*args)
    end

    # @!method request!(type, body)
    # Calls a request with custom method type unsafely
    #
    # @param  [String] type
    # @param  [Hash]   body
    # @return (see Adapter#call!)
    # @raise  (see Adapter#call!)
    #
    def request!(*args)
      adapter.call! prepare_request(*args)
    end

    private

    def prepare_request(type, body = {})
      @request.with_body(body).with_type(type.to_s)
    end

    def adapter
      @adapter ||= Adapter.for_api(@api)
    end

    def clone_with(&block)
      dup.tap { |client| client.instance_eval(&block) }
    end
  end
end
