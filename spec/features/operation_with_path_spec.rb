RSpec.describe "operation with path" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::Client < Evil::Client
      operation do
        http_method :get
        path { "users" }
        response :success, 200
      end

      operation :find_users

      operation :find_user do
        path { |id:, **| "users/#{id}" }
      end

      operation :login do |settings|
        path { "login/#{settings.token}" }
      end
    end

    stub_request :get, //
  end

  let(:client) { Test::Client.new "foo", user: "bar", version: 3, token: "baz" }

  it "uses default path" do
    client.operations[:find_users].call

    expect(a_request(:get, "https://foo.example.com/api/v3/users"))
      .to have_been_made
  end

  it "uses request options" do
    client.operations[:find_user].call(id: 42)

    expect(a_request(:get, "https://foo.example.com/api/v3/users/42"))
      .to have_been_made
  end

  it "uses settings" do
    client.operations[:login].call

    expect(a_request(:get, "https://foo.example.com/api/v3/login/baz"))
      .to have_been_made
  end
end
