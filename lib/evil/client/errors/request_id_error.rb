module Evil::Client::Errors
  # Exception for the case API is initialized without request_id
  #
  # @api public
  #
  class RequestIDError < RuntimeError
    # Initializes the exception w/o parameters
    def initialize
      super \
        "Request ID should be set for API. Either use Rails, or set it manually"
    end
  end
end
