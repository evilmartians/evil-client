module Evil::Client::RSpec
  # The object to be compared to received request by method and path only
  class RequestMock
    # Initializes the mock object with method and path
    #
    # @param [#to_s] method
    # @param [#to_s] path
    #
    def initialize(method, path)
      @method = method
      @path = path
    end

    # Checks whether other (actual) request matches the mock
    #
    # @param [Evil::Client::Request] other
    #
    # @return [Boolean]
    #
    def ==(other)
      to_proc[other]
    end
    alias_method :eql?, :==

    # Returns a condition to be added to further ones
    #
    # @return [Proc]
    #
    def to_proc
      proc { |req| req.method == method && (path.nil? || req.path == path) }
    end

    private

    attr_reader :method, :path
  end
end
