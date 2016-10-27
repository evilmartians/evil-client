RSpec.describe Evil::Client::Middleware do
  before do
    class Test::Bar
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env) << " bar"
      end
    end

    class Test::Baz
      def initialize(app)
        @app = app
      end

      def call(env)
        @app.call(env) << " baz"
      end
    end
  end

  let(:connection) do
    double(:connection).tap do |conn|
      allow(conn).to receive(:call) { |value| value << " foo" }
    end
  end

  let(:middleware) do
    described_class.new do |settings|
      run Test::Baz if settings.baz
      run Test::Bar
    end
  end

  it "builds full stack parameterized by settings" do
    settings = double baz: false
    response = middleware.finalize(settings).call(connection).call("qux")
    expect(response).to eq "qux foo bar"

    settings = double baz: true
    response = middleware.finalize(settings).call(connection).call("qux")
    expect(response).to eq "qux foo bar baz"
  end
end
