class Evil::Client
  #
  # Exception to be risen when remote API responded with undefined status
  #
  class ResponseError < RuntimeError
    # @!attribute [r] schema
    # @return [Evil::Client::Container::Operation::Schema] The operation schema
    attr_reader :schema

    # @!attribute [r] settings
    # @return [Evil::Client::Settings] The settings used by the request
    attr_reader :settings

    # @!attribute [r] response
    # @return [Array] The rack response to the request
    attr_reader :response

    # @!attribute [r] settings
    # @return [Integer] The status of the [#response]
    attr_reader :status

    # @!attribute [r] headers
    # @return [Hash] The hash of the [#response] headers
    attr_reader :headers

    # @!attribute [r] settings
    # @return [Enumerable] The enumerable object describing the [#response] body
    attr_reader :body

    private

    def initialize(schema, settings, response)
      @schema   = schema
      @settings = settings
      @response = response
      @status, @headers, @body = Array(response)

      super "remote API responded to #{@schema}" \
            " with unexpected status #{@status}"
    end
  end
end
