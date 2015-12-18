require "delegate"
require "equalizer"
require "hashie/mash"
require "logger"
require "mime-types"
require "mustermann"
require "net/http"
require "net/https"
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
    require_relative "client/base_uri"
    require_relative "client/request"
    require_relative "client/response"
    require_relative "client/adapter"
    require_relative "client/rails" if defined? ::Rails

    # Instantiates client from the base url
    #
    # @param [String] base_url
    #
    # @return [Evil::Client]
    #
    def self.new(base_url)
      base_uri = BaseURI.parse base_url
      request  = Request.new base_uri.path
      adapter  = Adapter.build base_uri

      super(base_uri, adapter, request)
    end

    # Initializes a client instance with current request and adapter
    #
    # @param [URI] base_uri
    # @param [Evil::Client::Adapter] adapter
    # @param [Evil::Client::Request] current_request
    #
    def initialize(base_uri, adapter, current_request)
      @base_uri        = base_uri
      @adapter         = adapter
      @current_request = current_request
    end

    # @!attribute [r] base_uri
    #
    # @return [URI] the base URI
    #
    attr_reader :base_uri

    # @!attribute [r] adapter
    #
    # @return [Evil::Client::Adapter] the adapter to http(s) client
    #
    attr_reader :adapter

    # @!attribute [r] current_request
    #
    # @return [Evil::Client::Request] the lazily prepared current request
    # @api private
    #
    attr_reader :current_request

    # Returns full URI that corresponds to the current path
    #
    # @return [String]
    #
    def uri
      full_path = current_request.full_path
      base_uri.dup.tap { |uri| uri.path = full_path }.to_s
    end

    # Adds part to the URI
    #
    # @param (see Evil::Client::Request#with_path)
    #
    # @return [Evil::Client] updated client
    #
    def path(*values)
      clone_with current_request.with_path(values)
    end

    # Adds parameters to the query
    #
    # @param (see Evil::Client::Request#with_query)
    #
    # @return [Evil::Client] updated client
    #
    def query(values)
      clone_with current_request.with_query(values)
    end

    # Adds parameters to the body
    #
    # @param (see Evil::Client::Request#with_body)
    #
    # @return [Evil::Client] updated client
    #
    def body(values)
      clone_with current_request.with_body(values)
    end

    # Sets new method for sending the request
    #
    # @param (see Evil::Client::Request#with_method)
    #
    # @return [Evil::Client] updated client
    #
    def method(value)
      clone_with current_request.with_method(value)
    end

    # Adds headers
    #
    # @param (see Evil::Client::Request#with_headers)
    #
    # @return [Evil::Client] updated client
    #
    def headers(values)
      clone_with current_request.with_headers(values)
    end

    # @!method get(query)
    # Calls a GET request safely
    #
    # @param  [Hash] query
    # @return [Hashie::Mash]
    #
    def get(data = {})
      query(data).request("get")
    end

    # @!method get!(query)
    # Calls a GET request unsafely
    #
    # @param  (see #get)
    # @return (see #get)
    # @raise  (see #request!) in case of error response
    #
    def get!(data = {})
      query(data).request!("get")
    end

    # @!method post(body)
    # Calls a POST request safely
    #
    # @param [Hash] body
    # @return [Hashie::Mash]
    #
    def post(data = {})
      body(data).request("post")
    end

    # @!method post!(body)
    # Calls a POST request unsafely (raises in case of error response)
    #
    # @param  (see #post)
    # @return (see #post)
    # @raise  (see #request!) in case of error response
    #
    def post!(data = {})
      body(data).request!("post")
    end

    # @!method patch(body)
    # Calls a PATCH request safely
    #
    # @param  (see #post)
    # @return (see #post)
    #
    def patch(data = {})
      body(data).request("patch")
    end

    # @!method patch!(body)
    # Calls a PATCH request unsafely (raises in case of error response)
    #
    # @param  (see #post!)
    # @return (see #post!)
    # @raise  (see #post!)
    #
    def patch!(data = {})
      body(data).request!("patch")
    end

    # @!method put(body)
    # Calls a PUT request safely
    #
    # @param  (see #post)
    # @return (see #post)
    #
    def put(data = {})
      body(data).request("put")
    end

    # @!method put!(body)
    # Calls a PUT request unsafely (raises in case of error response)
    #
    # @param  (see #post!)
    # @return (see #post!)
    # @raise  (see #post!)
    #
    def put!(data = {})
      body(data).request!("put")
    end

    # @!method delete(body)
    # Calls a DELETE request safely
    #
    # @param  (see #post)
    # @return (see #post)
    #
    def delete(data = {})
      body(data).request("delete")
    end

    # @!method delete!(body)
    # Calls a DELETE request unsafely (raises in case of error response)
    #
    # @param  (see #post!)
    # @return (see #post!)
    # @raise  (see #post!)
    #
    def delete!(data = {})
      body(data).request!("delete")
    end

    # @!method request(method)
    # Calls a request with custom method safely
    #
    # @param  [#to_s] method
    # @return (see #request!)
    #
    def request(value)
      adapter.call method(value).current_request
    end

    # @!method request!(method)
    # Calls a custom request unsafely (raises in case of error response)
    #
    # @param  [#to_s] method
    # @return (see Adapter#call!)
    # @raise  (see Adapter#call!)
    #
    def request!(value)
      adapter.call! method(value).current_request
    end

    private

    def clone_with(request)
      dup.tap { |client| client.instance_eval { @current_request = request } }
    end
  end
end
