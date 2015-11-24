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

    # Sends the request to API and returns either successful or errored response
    #
    # @param (see #call!)
    #
    # @return (see #call!)
    #
    def call(request)
      send_request(request).content
    end

    # Sends the request to API and raises in case of error response
    #
    # @param [Evil::Client::Request] request
    #
    # @return [Hashie::Mash] object containing a response
    #
    # @raise [Evil::Client::Errors::ResponseError]
    #   when API responded with error
    #
    def call!(request)
      response = send_request(request)
      return response.content if response.success?
      fail ResponseError.new(request, response)
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
      raw_response = connection.request(*request.to_a)
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
