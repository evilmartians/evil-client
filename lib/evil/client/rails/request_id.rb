module Evil::Client::Rails
  # Rails-specific provider for API client's request ID
  #
  # @api private
  #
  class RequestID
    KEY = "action_dispatch.request_id".freeze

    def self.call
      Thread.current[KEY]
    end

    def initialize(app)
      @app = app
    end

    def call(env)
      Thread.current[KEY] = env[KEY]
      @app.call env
    ensure
      Thread.current[KEY] = nil
    end
  end
end
