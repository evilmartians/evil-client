class Evil::Client::Request
  # Utility to build final headers of a prepared request
  #
  # @api private
  #
  class Headers < Base
    # Returns the resulting headers
    #
    # @return [Hash]
    #
    def build
      response_type_headers
        .update(content_type_headers)
        .update(request_id_headers)
        .update(request.headers) # customized by user
        .inject({}) { |h, (key, value)| h.merge(key.to_s => value.to_s) }
    end

    private

    def multipart?
      Items.new(request.body).multipart?
    end

    def request_id
      @request_id ||= RequestID.value
    end

    def content_type_headers
      multipart? ? multipart_headers : form_url_headers
    end

    def response_type_headers
      { "Accept" => "application/json" }
    end

    def request_id_headers
      request_id ? { "X-Request-Id" => request_id } : {}
    end

    def form_url_headers
      { "Content-Type" => "www-url-form-encoded; charset=utf-8" }
    end

    def multipart_headers
      { "Content-Type" => "multipart/form-data; charset=utf-8" }
    end

    # Middleware that takes a request_id from the Rack environment
    #
    # @api private
    #
    class RequestID
      # @api private
      class << self
        # Rack environment key for extracting [#value] from
        #
        # @return [String]
        #
        def key
          @key || "HTTP_X_REQUEST_ID"
        end

        # Subclasses the middleware with a specific Rack env [#key]
        #
        # @param [#to_s] custom_key
        #
        # @return [Class]
        #
        def with(custom_key)
          Class.new(self) { @key = custom_key.to_s }
        end

        # Provides access to a request_id extracted from Rack env by [#key]
        #
        # @return [String, nil]
        #
        def value
          Thread.current[key] if key
        end
      end

      # Initializes the middleware
      #
      # @param [Class] app Rack application
      #
      def initialize(app)
        @app = app
        @key = self.class.key
      end

      # Calls the middleware to extract a request id from Rack environment
      #
      # @param [Hash] env Rack environment
      #
      # @return [Hash]
      #
      def call(env)
        Thread.current[@key] = env[@key]
        @app.call env
      ensure
        Thread.current[@key] = nil
      end
    end
  end
end
