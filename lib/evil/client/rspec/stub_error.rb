module Evil::Client::RSpec
  # The exception to be raised when unstubbed request is sent to client
  class StubError < RuntimeError
    # Initializes the exception for the request
    #
    # @param [Evil::Client::Request] request
    #
    def initialize(request)
      super "Unexpected request has been received:\n#{request.inspect}"
    end
  end
end
