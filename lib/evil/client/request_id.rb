class Evil::Client
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
