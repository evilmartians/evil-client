class Evil::Client::Operation
  require_relative "response_error"
  require_relative "unexpected_response_error"

  # Processes rack responses using an operation's schema
  class Response
    extend Dry::Initializer::Mixin
    param :schema

    # Processes rack responses returned by [Dry::Cluent::Connection]
    #
    # @param  [Array] array Rack-compatible array of response data
    # @return [Object]
    # @raise  [Evil::Client::ResponseError] if it is required by the schema
    #
    def handle(array)
      status, header, body = array
      response = Rack::Response.new(body, status, header)

      handler = response_schema(response)
      data    = handler[:coercer].call response: response,
                                       body:     response.body,
                                       header:   response.header

      handler[:raise] ? fail(ResponseError.new(schema, status, data)) : data
    end

    private

    def name
      @name ||= schema[:name]
    end

    def response_schema(response)
      schema[:responses].fetch response.status do
        fail UnexpectedResponseError.new(schema, response)
      end
    end
  end
end
