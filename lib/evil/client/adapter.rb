class Evil::Client
  # Sends the request to remote API
  #
  # It is responsible for:
  #
  # * sending prepared requests to the server
  # * deserializing a response body into the Request object
  # * processing error responses
  #
  # @api private
  #
  class Adapter
    include Errors

    # @api private
    class << self
      # @!attribute [rw] default_logger
      #
      # @return [Logger, nil] The default logger
      #
      attr_accessor :default_logger

      # Builds the adapter depending on uri with customizable logger
      #
      # @param [URI] base_uri
      # @param [Logger] logger
      #
      # @return [Evil::Client::Adapter]
      #
      def build(base_uri, logger = default_logger)
        client = Net::HTTP.new base_uri.host, base_uri.port
        new(client, logger)
      end
    end

    # Initializes the adapter with http(s) client and logger
    #
    # @param [Object] client
    # @param [Logger] logger
    #
    def initialize(client, logger)
      @client = client
      @logger = logger
    end

    # @!attribute [r] client
    #
    # It should never be called in test env (raises an exception)
    #
    # @return [Net::HTTP] the underlying HTTP client
    #
    attr_reader :client

    # @!attribute [r] logger
    #
    # @return [Logger]
    #
    attr_reader :logger

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

    # The access point that sends prepared requests to remote client
    #
    # @param [Evil::Client::Request] request
    #
    # @return [Evil::Client::Response]
    #
    def send_request(request)
      response = client.send_request(*request.to_a)
      Response.new(response.code, response.body)
    end
  end
end
