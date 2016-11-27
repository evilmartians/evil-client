class Evil::Client::Middleware::Base
  def call(env, schema, options)
    @app.call(env, schema, options)
  end

  private

  def initialize(app)
    @app = app
  end
end
