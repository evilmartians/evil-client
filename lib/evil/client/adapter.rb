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
      # @return [Logger, nil] The logger used by all connections
      #
      attr_accessor :logger
    end

    # Initializes the adapter with custom logger
    #
    # @param [Logger] logger
    #
    def initialize(logger = nil)
      @logger = logger || self.class.logger
    end

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
      type, host, path, port, body, headers = request.to_a
      client   = Net::HTTP.new(host, port)
      response = client.send_request(type, path, body, headers)

      Response.new(response.code, response.body)
    end
  end
end
