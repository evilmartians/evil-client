class Evil::Client::Request
  # Base class for builders of request attributes (path, body, headers)
  #
  # @api private
  #
  class Base
    # Instantiates the utility and builds the attribute
    #
    # @param [Evil::Client::Request] request
    #
    # @return [Object]
    #
    def self.build(request)
      new(request).build
    end

    # @!attribute [r] request
    #
    # @return [Evil::Client::Request] the request whose attribute to be provided
    #
    attr_reader :request

    # Initializes the utility
    #
    # @param [Evil::Client::Request] request
    #
    def initialize(request)
      @request = request
    end

    # Builds a final attribute
    #
    # @return [Object]
    #
    def build
    end
  end
end
