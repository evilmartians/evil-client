class Evil::Client::Operation
  class UnexpectedResponseError < RuntimeError
    attr_reader :response

    private

    def initialize(schema, response)
      @response = response

      message = "Response to operation '#{schema[:key]}'" \
                " has unexpected http status #{response.status}."
      message << " See #{schema[:doc]} for details." if schema[:doc]
      super message
    end
  end
end
