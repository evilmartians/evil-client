require "logger"

class Evil::Client
  # Sends the request to remote API and processes the response
  #
  # It is responsible for:
  # * sending requests to the server
  # * deserializing a response body
  # * handling error responses
  #
  # @api private
  #
  class Adapter

    include Errors

    # @api private
    class << self
      # @!attribute [rw] logger
      #
      # @return [::Logger, nil] The logger used by all connections
      #
      attr_accessor :logger
    end

    # Initializes the adapter to selected API <specification>
    #
    # @param [Evil::Client::API] api
    #
    # @return [Evil::Client::Adapter]
    #
    def self.for_api(api)
      new(base_url: api.base_url)
    end

    # @!method initialize(options)
    # Initializes the adapter with base_url and optional logger
    #
    # @param [Hash] options
    # @option options [String] :base_url
    # @option options [String] :logger
    #
    def initialize(base_url:, **options)
      @base_url = base_url
      @logger   = options.fetch(:logger) { self.class.logger }
    end

    # Sends the request to API, handles and returns its response
    #
    # @param [Evil::Client::Request] request
    # @param [Proc] error_handler Custom handler of error responses
    #
    # @return [Object] Deserialized body of a server response
    #
    # @yield block when API responds with error (status 4** or 5**)
    # @yieldparam [HTTP::Message] The raw message from the server
    # @see http://www.rubydoc.info/gems/httpclient/HTTP/Message
    #   Docs for HTTP::Message format
    #
    # @raise [Evil::Client::Errors::ResponseError]
    #   when API responds with error and no block given
    #
    def call(request, &error_handler)
      response = send_request(request)
      return response.content if response.success?
      handle_error(request, response, &error_handler)
    end

    private

    def connection
      @connection ||= begin
        json_client = HTTPClient.new(base_url: @base_url)
        json_client.debug_dev = @logger
        json_client
      end
    end

    def send_request(request)
      raw_response = connection.public_send(*request.to_a)
      Response.new(raw_response)
    end

    def handle_error(request, response)
      if block_given?
        yield(response)
      else
        fail ResponseError.new(request, response)
      end
    end
  end
end
