RSpec.describe "operation with headers" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::Client < Evil::Client
      operation do
        http_method :get
        path { "data" }

        headers do
          attribute :foo
          attribute :bar, type: Dry::Types["strict.string"]
          attribute :baz, optional: true
        end

        response :success, 200
      end

      operation :clear_data do
      end

      operation :get_data do
        headers
      end

      operation :find_data do |settings|
        headers do
          attribute :foo  if settings.version < 2
          attribute :bar, type: Dry::Types["coercible.int"]
        end
      end
    end

    stub_request(:any, //)
  end

  let(:path)   { "https://foo.example.com/api/v3/data" }
  let(:client) { Test::Client.new("foo", version: 3, user: "bar") }

  it "uses default value" do
    client.operations[:clear_data].call foo: "FOO", bar: "BAR", baz: "BAZ"

    request = a_request(:get, path) do |req|
      expect(req.headers).to include "Foo" => "FOO",
                                     "Bar" => "BAR",
                                     "Baz" => "BAZ"
    end

    expect(request).to have_been_made
  end

  it "ingnores unknown attributes" do
    client.operations[:clear_data]
      .call foo: "FOO", bar: "BAR", baz: "BAZ", qux: "QUX"

    request = a_request(:get, path).with do |req|
      expect(req.headers.keys).not_to include "Qux"
    end

    expect(request).to have_been_made
  end

  it "requires mandatory headers" do
    expect { client.operations[:clear_data].call bar: "BAR", baz: "BAZ" }
      .to raise_error(ArgumentError)
  end

  it "applies type constraints" do
    expect { client.operations[:clear_data].call foo: "FOO", bar: :BAR }
      .to raise_error(TypeError)
  end

  it "skips optional headers" do
    client.operations[:clear_data].call foo: "FOO", bar: "BAR"

    request = a_request(:get, path).with do |req|
      expect(req.headers.keys).not_to include "Baz"
    end

    expect(request).to have_been_made
  end

  it "can undefine default headers" do
    client.operations[:get_data].call

    expect(a_request(:get, path)).to have_been_made
  end

  it "can reload default headers for a specific operation" do
    client.operations[:find_data].call foo: "FOO", bar: "01", baz: "BAZ"

    request = a_request(:get, path).with do |req|
      expect(req.headers).to include "Bar" => "1"
      expect(req.headers.keys).not_to include "Foo"
      expect(req.headers.keys).not_to include "Baz"
    end

    expect(request).to have_been_made
  end
end
