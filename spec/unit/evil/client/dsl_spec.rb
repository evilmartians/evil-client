RSpec.describe Evil::Client::DSL do
  before do
    class Test::Middleware
      def initialize(app)
        @app = app
      end

      def call(env)
        app.call(env).reverse
      end
    end

    class Test::Foo
      extend Evil::Client::DSL

      settings do
        param  :version,  type: Dry::Types["coercible.int"]
        option :user,     type: Dry::Types["strict.string"]
        option :password, type: Dry::Types["strict.string"]
      end

      base_url do |settings|
        "https://example.com/v#{settings.version}"
      end

      connection do |_|
        run Test::Middleware
      end

      operation do |settings|
        security { basic_auth settings.user, settings.password }
      end

      operation :find_user do |_|
        path { |id:| "users/#{id}" }
        http_method :get

        response 200 do |data|
          data.reverse
        end
      end
    end
  end

  subject { Test::Foo.finalize(4, user: "foo", password: "bar") }

  it "builds a proper schema" do
    operation = subject[:operations][:find_user]

    expect(operation[:security].call)
      .to eq headers: { "authorization" => "Basic Zm9vOmJhcg==" }
    expect(operation[:path].call(id: 3)).to eq "users/3"
    expect(operation[:method]).to eq "get"

    expect(operation[:responses][200][:coercer].call "foo").to eq "oof"
  end
end
