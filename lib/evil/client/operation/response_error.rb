class Evil::Client::Operation
  class ResponseError < RuntimeError
    attr_reader :status, :data

    private

    def initialize(schema, status, data)
      @status = status
      @data   = data
      super "Response to operation '#{schema[:key]}' has http status #{status}"
    end
  end
end
