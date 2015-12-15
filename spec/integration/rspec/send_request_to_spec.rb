require "evil/client/rspec"

describe "send_request_to" do
  before { stub_request :any, // }

  let(:client) { Evil::Client.new "https://localhost/foo" }

  it "matchers reseiving requests" do
    expect { client.post }.to send_request_to(client)
  end

  it "can be negated" do
    expect { 1 }.not_to send_request_to(client)
  end

  it "matches type using #with" do
    expect { client.post }
      .to send_request_to(client)
      .with(method: 'POST')
  end

  it "matches type using #with_method" do
    expect { client.post }
      .to send_request_to(client)
      .with_method('POST')
  end

  it "ignores wrong type" do
    expect { client.get }
      .not_to send_request_to(client)
      .with(method: 'POST')
  end

  it "matches path using #with" do
    expect { client.path(:bar).post }
      .to send_request_to(client)
      .with(path: "/foo/bar")
  end

  it "matches path using #with_path" do
    expect { client.path(:bar).post }
      .to send_request_to(client)
      .with_path("/foo/bar")
  end

  it "ignores wrong path" do
    expect { client.post }
      .not_to send_request_to(client)
      .with(path: "/foo/bar")
  end

  it "matches query using #with" do
    expect { client.query(bar: :bar).post }
      .to send_request_to(client)
      .with(query: { bar: :bar })
  end

  it "matches query using #with_query" do
    expect { client.query(bar: :bar).post }
      .to send_request_to(client)
      .with_query(bar: :bar)
  end

  it "ignores wrong query" do
    expect { client.query(bar: :bar, foo: :foo).post }
      .not_to send_request_to(client)
      .with(query: { bar: :bar })
  end

  it "matches body using #with" do
    expect { client.body(bar: :bar).post }
      .to send_request_to(client)
      .with(body: { bar: :bar })
  end

  it "matches body using #with_body" do
    expect { client.body(bar: :bar).post }
      .to send_request_to(client)
      .with_body(bar: :bar)
  end

  it "ignores wrong body" do
    expect { client.body(bar: :bar, foo: :foo).post }
      .not_to send_request_to(client)
      .with(body: { bar: :bar })
  end

  it "matches headers using #with" do
    expect { client.headers('X-Bar' => :Bar).post }
      .to send_request_to(client)
      .with(headers: { 'X-Bar' => :Bar })
  end

  it "matches headers using #with_headers" do
    expect { client.headers('X-Bar' => :Bar).post }
      .to send_request_to(client)
      .with_headers('X-Bar' => :Bar)
  end

  it "ignores wrong headers" do
    expect { client.headers('X-Bar' => :Bar, 'X-Foo' => :Foo).post }
      .not_to send_request_to(client)
      .with(headers: { 'X-Bar' => :Bar })
  end

  it "supports long chains" do
    expect { client.body(bar: :bar, foo: :foo).post }
      .to send_request_to(client)
      .with(body: { bar: :bar })
      .with(body: { foo: :foo })
  end
end
