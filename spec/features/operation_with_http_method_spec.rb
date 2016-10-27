RSpec.describe "operation with http_method" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::Client < Evil::Client
      operation do |settings|
        http_method settings.version > 1 ? :post : :get
        path { "data" }
        response 200
      end

      operation :clear_data do
        http_method :delete
      end

      operation :find_data

      operation :reset_data do |settings|
        http_method settings.version > 2 ? :patch : :put
      end
    end

    stub_request(:any, //)
  end

  let(:path)   { "https://foo.example.com/api/v3/data" }
  let(:client) { Test::Client.new("foo", version: 3, user: "bar") }

  it "uses default value" do
    client.operations[:find_data].call

    expect(a_request(:post, path)).to have_been_made
  end

  it "reloads default value with operation-specific one" do
    client.operations[:clear_data].call

    expect(a_request(:delete, path)).to have_been_made
  end

  it "is customizeable by settings" do
    client.operations[:reset_data].call

    expect(a_request(:patch, path)).to have_been_made
  end
end
