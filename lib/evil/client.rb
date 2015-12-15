require "net/http"
require "net/https"
require "delegate"
require "hashie/mash"
require "logger"
require "mime-types"
require "pathname"
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
    require_relative "client/request"
    require_relative "client/response"
    require_relative "client/adapter"
    require_relative "client/rails" if defined? ::Rails

    # Initializes a client instance with base url
    #
    # @param [String] base_url
    #
    def initialize(base_url)
      @request = Request.new(base_url)
      @adapter = Adapter.new
    end

    # The underlying adapter
    #
    # @return [Evil::Client::Adapter]
    #
    attr_reader :adapter

    # Adds part to the URI
    #
    # @param (see Evil::Client::Request#with_path)
    #
    # @return [Evil::Client] updated client
    #
    def path(*values)
      clone_with @request.with_path(values)
    end

    # Adds parameters to the query
    #
    # @param (see Evil::Client::Request#with_query)
    #
    # @return [Evil::Client] updated client
    #
    def query(values)
      clone_with @request.with_query(values)
    end

    # Adds parameters to the body
    #
    # @param (see Evil::Client::Request#with_body)
    #
    # @return [Evil::Client] updated client
    #
    def body(values)
      clone_with @request.with_body(values)
    end

    # Sets new method for sending the request
    #
    # @param (see Evil::Client::Request#with_method)
    #
    # @return [Evil::Client] updated client
    #
    def method(value)
      clone_with @request.with_method(value)
    end

    # Adds headers
    #
    # @param (see Evil::Client::Request#with_headers)
    #
    # @return [Evil::Client] updated client
    #
    def headers(values)
      clone_with @request.with_headers(values)
    end

    # Returns full URI that corresponds to the current path
    #
    # @return [String]
    #
    def uri
      path = Request::Path.build(@request)
      "#{@request.protocol}://#{@request.host}#{path}"
    end

    # Returns the current state of the prepared request
    #
    # @return [Evil::Client::Request]
    # @api private
    #
    def current_request
      @request
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
      dup.tap { |client| client.instance_eval { @request = request } }
    end
  end
end
