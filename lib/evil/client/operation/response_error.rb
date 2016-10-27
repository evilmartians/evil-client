class Evil::Client::Operation
  class ResponseError < RuntimeError
    attr_reader :response

    private

    def initialize(schema, status, response)
      @response = response
      super "Response to operation '#{schema[:key]}' has http status #{status}"
    end
  end
end
