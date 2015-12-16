module Evil::Client::RSpec
  class UnknownRequestError < RuntimeError
    # Initializes the exception for the request
    #
    # @param [Evil::Client::Request] request
    # @return [UnknownRequestError]
    #
    def initialize(request)
      super <<-MESSAGE.gsub(/ +\|/, "")
        |Unexpected request has been sent to http client:
        |  #{request.method.upcase} #{request.path}
        |  with headers: #{request.headers}
        |  with body:    #{request.body}
        |  with query:   #{request.query}
      MESSAGE
    end
  end
end
