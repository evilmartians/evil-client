class Evil::Client::Operation
  class UnexpectedResponseError < RuntimeError
    attr_reader :status, :data

    private

    def initialize(schema, status, data)
      @status = status
      @data   = data

      message = "Response to operation '#{schema[:key]}'" \
                " with http status #{status} and body #{data}" \
                " cannot be processed."
      message << " See #{schema[:doc]} for details." if schema[:doc]

      super message
    end
  end
end
