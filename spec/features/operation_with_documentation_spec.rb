RSpec.describe "operation with documentation" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::Client < Evil::Client
      operation do |settings|
        documentation "https://docs.example.com/v#{settings.version}/index.html"
        http_method :get
        path { "data" }
      end

      operation :clear_data
      operation :find_data do |settings|
        documentation "https://docs.example.com/v#{settings.version}/findData"
      end
    end

    stub_request(:any, //)
  end

  let(:client) { Test::Client.new("foo", version: 3, user: "bar") }

  it "displays default documentation in exception messages" do
    begin
      client.operations[:clear_data].call
    rescue => error
      expect(error.message).to include "https://docs.example.com/v3/index.html"
    else
      fail
    end
  end

  it "reloads default value with operation-specific one" do
    begin
      client.operations[:find_data].call
    rescue => error
      expect(error.message).to include "https://docs.example.com/v3/findData"
    else
      fail
    end
  end
end
