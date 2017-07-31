RSpec.describe "operation request" do
  before do
    # Adds header tag to request/response
    class Test::Middleware
      extend Dry::Initializer
      param :app

      def call(env)
        env["HTTP_Variables"].update tags
        status, headers, body = app.call(env)
        [status, headers.merge(tags), body]
      end
    end

    class Foo < Test::Middleware
      def tags; { "Tag" => "Foo" }; end
    end

    class Bar < Test::Middleware
      def tags; { "Tag" => "Bar" }; end
    end

    load "spec/fixtures/test_client.rb"
    class Test::Client < Evil::Client
      middleware { Foo }

      scope :crm do
        middleware { Bar }
      end
    end

    stub_request(:any, //).to_return(status: 200, body: [], headers: {})
  end

  subject do
    Test::Client.new(subdomain: "europe", user: "andy", password: "foo")
                .crm(version: 4)
                .users
                .fetch(id: 1)
  end

  it "applies middleware in a proper order" do
    expected_request = \
      a_request(:get, "https://europe.example.com/crm/v4/users/1")
      .with headers: { "Tag" => "Bar" }

    expect(subject).to eq [200, { "Tag" => "Foo" }, []]
    expect(expected_request).to have_been_made
  end
end
