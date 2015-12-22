require "evil/client/rspec"

describe "matching expectations" do
  let!(:client) { Evil::Client.new "localhost" }

  let!(:expectation_error) { RSpec::Mocks::MockExpectationError }

  it "expects the request method" do
    allow(client)
      .to receive_request(:get)
      .and_respond(200, "name" => "Luka")

    expect(client).not_to receive_request(:post)
    expect(client).to receive_request(:get)

    client.get
  end

  it "expects the request path" do
    allow(client)
      .to receive_request(:get)
      .and_respond(200)

    expect(client).not_to receive_request(:get, "/foo")
    expect(client).to receive_request(:get, "/foo/bar")

    client.path(:foo, :bar).get
  end

  it "supports counting requests" do
    allow(client)
      .to receive_request(:get)
      .and_respond(200)

    expect(client).to receive_request(:get, "/foo/:name").twice
    expect(client).not_to receive_request(:get, "/foo/:name")

    client.path(:foo, :bar).get
    client.path(:foo, :baz).get
  end
end
