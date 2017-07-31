class Evil::Client
  #
  # Object that sends rack-compatible request environment to remote API,
  # and wraps a response into rack-compatible array of [status, headers, body].
  #
  # @see http://www.rubydoc.info/github/rack/rack/master/file/SPEC
  #
  module Connection
    extend self

    # Makes the request by taking rack env and returning rack response
    #
    # @param  [Hash<String, Object>] env Rack environment
    # @return [Array] Rack-compatible response
    #
    def call(env)
      request = Rack::Request.new(env)
      with_logger_for request do
        open_http_connection_for request do |http|
          res = http.request build_from(request)
          [res.code.to_i, Hash(res.header), Array(res.body)]
        end
      end
    end

    private

    def open_http_connection_for(req)
      Net::HTTP.start req.host, req.port, use_ssl: req.ssl? do |http|
        yield(http)
      end
    end

    def build_from(request)
      uri     = URI request.url
      body    = request.body
      type    = request.env["REQUEST_METHOD"].capitalize
      headers = request.env["HTTP_Variables"]

      Net::HTTP.const_get(type).new(uri).tap do |req|
        req.body = body
        headers.each { |key, val| req[key] = val }
      end
    end

    def with_logger_for(request)
      logger = request.logger
      log_request(logger, request)
      yield.tap { |response| log_response(logger, response) }
    end

    def log_request(logger, request)
      return unless logger

      logger.info(self) { "sending request:" }
      logger.info(self) { " Url     | #{request.url}" }
      logger.info(self) { " Headers | #{request.env['HTTP_Variables']}" }
      logger.info(self) { " Body    | #{request.body}" }
    end

    def log_response(logger, response)
      return unless logger

      status, headers, body = Array response
      logger.info(self) { "receiving response:" }
      logger.info(self) { " Status  | #{status}" }
      logger.info(self) { " Headers | #{headers}" }
      logger.info(self) { " Body    | #{body}" }
    end
  end
end
