require "evil/client/rspec"

describe "receive_request_to" do
  before { stub_request :any, // }

  let(:client) { Evil::Client.new "https://localhost/foo" }

  it "matchers reseiving requests" do
    expect(client).to receive_request(:post, "foo")

    client.post
  end

  it "can be negated" do
    expect(client).not_to receive_request
  end

  it "matches type" do
    expect(client).to receive_request(:post, "/foo")
    expect(client).not_to receive_request(:put, "/foo")

    client.post
  end

  it "matches path" do
    expect(client).not_to receive_request(:post, "/foo")
    expect(client).not_to receive_request(:post, "/foo/bar/baz")
    expect(client).to receive_request(:post, "/foo/bar")

    client.path(:bar).post
  end

  it "matches strict query" do
    expect(client)
      .not_to receive_request(:post, "foo")
      .with_query(bar: :bar)

    expect(client)
      .to receive_request(:post, "foo")
      .with_query(bar: :bar, foo: :foo)

    client.query(bar: :bar, foo: :foo).post
  end

  it "matches partial query" do
    expect(client)
      .to receive_request(:post, "foo")
      .with_query_including(bar: :bar)

    client.query(bar: :bar, foo: :foo).post
  end

  it "matches strict body" do
    expect(client)
      .not_to receive_request(:post, "foo")
      .with_body(bar: :bar)

    expect(client)
      .to receive_request(:post, "foo")
      .with_body(bar: :bar, foo: :foo)

    client.post(bar: :bar, foo: :foo)
  end

  it "matches partial body" do
    expect(client)
      .to receive_request(:post, "foo")
      .with_body_including(bar: :bar)

    client.post(bar: :bar, foo: :foo)
  end

  it "matches strict headers" do
    expect(client)
      .not_to receive_request(:post, "foo")
      .with_headers("X-Bar" => "Bar")

    expect(client)
      .to receive_request(:post, "foo")
      .with_headers("X-Bar" => "Bar", "X-Foo" => "Foo")

    client.headers("X-Bar" => "Bar", "X-Foo" => "Foo").post
  end

  it "matches partial headers" do
    expect(client)
      .to receive_request(:post, "foo")
      .with_headers_including("X-Bar" => "Bar")

    client.headers("X-Bar" => "Bar", "X-Foo" => "Foo").post
  end

  it "supports lazy chainining" do
    expect(client).to receive_request.with_body(bar: :bar).with_body(foo: :foo)

    client.post(bar: :bar, foo: :foo)
  end
end
