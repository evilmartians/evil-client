class Evil::Client::Request
  # Utility to build a final body of a prepared request
  #
  # @api private
  #
  class Body < SimpleDelegator
    # Instantiates and calls the utility to return the body
    #
    # @param [Evil::Client::Request] request
    #
    # @return [String]
    #
    def self.call(request)
      new(request).call
    end

    # @!attribute [r] request
    #
    # @return [Evil::Client::Request] the request whose body to be provided
    #
    attr_reader :request

    # Initializes the utility
    #
    # @param [Evil::Client::Request] request
    #
    def initialize(request)
      @request = request
    end

    # Returns the resulting body
    #
    # @return [String]
    #
    def call
      return if request.type == "get"
      return to_json if request.json?
      return to_plain unless request.multipart?
      to_multipart
    end

    private

    def to_multipart
      Multipart.call request.body
    end

    def to_json
      JSON.generate(request.body)
    end

    def to_plain
      Rack::Utils.build_nested_query(request.body)
    end
  end
end
