class Evil::Client::Middleware::Base
  def call(env)
    @app.call build(env)
  end

  private

  def initialize(app)
    @app = app
  end

  def build(env)
    env
  end
end
