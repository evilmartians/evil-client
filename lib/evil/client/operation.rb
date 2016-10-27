class Evil::Client
  # Carries a final schema for a single operation along with shared connection,
  # and uses it to send requests to the server
  class Operation
    require_relative "operation/request"
    require_relative "operation/response"

    extend Dry::Initializer::Mixin
    param :schema
    param :connection

    # Builds and sends a request and returns a response proccessed by schema
    #
    # @param  [IO, nil] file
    # @param  [Hash<Symbol, Object>] options
    # @return [Object]
    #
    def call(**options)
      req   = request.build(options)
      array = connection.call(req)
      response.handle(array)
    end

    private

    def request
      @request ||= Request.new(schema)
    end

    def response
      @response ||= Response.new(schema)
    end
  end
end
