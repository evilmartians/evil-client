RSpec.describe "middleware" do
  before do
    class Test::UpdateRequest
      def initialize(app)
        @app = app
      end

      def call(_env, schema, options)
        env = {
          path: "data/1",
          http_method: "get",
          format: "form",
          headers: { "baz" => "BAZ" },
          query: { "bar" => "baz" },
          body: { "qux" => 2 }
        }

        @app.call env, schema, options
      end
    end

    class Test::UpdateResponse
      def initialize(app)
        @app = app
      end

      def call(env, *params)
        response = @app.call(env, *params)
        response[2] = ["Hi!"]
        response
      end
    end

    class Test::Client < Evil::Client
      connection do |settings|
        run Test::UpdateRequest
        run Test::UpdateResponse if settings.version > 2
      end

      operation :find do
        path { "some" }
        http_method :post
        response :success, 200, format: :plain
      end
    end

    stub_request(:any, //)
  end

  it "updates requests" do
    request = a_request(:get, "https://foo.example.com/api/v3/data/1?bar=baz")
      .with do |req|
        expect(req.body).to eq "qux=2"
        expect(req.headers).to include "Baz" => "BAZ"
      end

    Test::Client.new("foo", version: 3, user: "bar").operations[:find].call

    expect(request).to have_been_made
  end

  it "updates responses" do
    response = \
      Test::Client.new("foo", version: 3, user: "bar")
      .operations[:find]
      .call

    expect(response).to eq "Hi!"
  end

  it "depends on settings" do
    response = \
      Test::Client.new("foo", version: 1, user: "bar")
      .operations[:find]
      .call

    expect(response).to be_nil
  end
end
