RSpec.describe "scoping" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::Client < Evil::Client
      operation :update_user do
        http_method :put
        path { |id:, **| "users/#{id}" }

        query do
          attribute :token
        end

        body format: :form do
          attribute :name
        end

        response 200
      end

      scope do
        param :token

        scope :users do
          scope do
            param :id

            def update(name:)
              operations[:update_user].call(id: id, token: token, name: name)
            end
          end
        end
      end
    end

    stub_request(:put, //)
  end

  let(:path) { "https://foo.example.com/api/v3/users/7?token=qux" }
  let(:client) do
    Test::Client.new "foo", version: 3, user: "bar"
  end

  it "provides access to params over nested scopes" do
    client["qux"].users[7].update name: "baz"

    expect(a_request(:put, path).with body: "name=baz").to have_been_made
  end
end
