RSpec.describe "operation with query" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::User < Evil::Client::Model
      attribute :name
    end

    class Test::Client < Evil::Client
      operation do
        http_method :get
        path { "users" }
        response 200
      end

      operation :filter do
        query do
          attribute :age,  type:     Dry::Types["coercible.int"]
          attribute :male, default:  proc { true }
          attribute :name, optional: true
        end
      end

      operation :search do
        query type: Test::User
      end
    end

    stub_request(:get, //)
  end

  let(:path)   { "https://foo.example.com/api/v3/users" }
  let(:client) { Test::Client.new "foo", user: "bar", version: 3, token: "baz" }

  it "provides a query from options ordered by name" do
    client.operations[:filter].call age: 48, male: false, name: "John"

    expect(a_request(:get, "#{path}?age=48&male=false&name=John"))
      .to have_been_made
  end

  it "uses http encoding" do
    client.operations[:filter].call age: 7, name: "Ян"

    expect(a_request(:get, "#{path}?age=7&male=true&name=%D0%AF%D0%BD"))
      .to have_been_made
  end

  it "skips unassigned optional attributes" do
    client.operations[:filter].call age: 7

    expect(a_request(:get, "#{path}?age=7&male=true")).to have_been_made
  end

  it "accepts a model" do
    client.operations[:search].call name: "Joe"

    expect(a_request(:get, "#{path}?name=Joe")).to have_been_made
  end

  it "ignores unspecified options" do
    client.operations[:search].call id: 1, name: "Joe"

    expect(a_request(:get, "#{path}?name=Joe")).to have_been_made
  end

  it "applies type restrictuions" do
    expect { client.operations[:filter].call id: 1, name: "Joe" }
      .to raise_error(KeyError)
  end

  it "supports nesting in a Rails style" do
    client.operations[:search].call name: {
      "first": "John", last: "Doe", middle: %w(Juan Andre)
    }
    query = [
      "name%5Bfirst%5D=John",
      "name%5Blast%5D=Doe",
      "name%5Bmiddle%5D%5B0%5D=Juan",
      "name%5Bmiddle%5D%5B1%5D=Andre"
    ].join("&")

    expect(a_request(:get, "#{path}?#{query}")).to have_been_made
  end
end
