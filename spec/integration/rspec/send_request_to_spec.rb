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

  it "matches protocol inline" do
    expect { client.post }
      .to send_request_to(client)
      .with(protocol: :https)
  end

  it "ignores wrong protocol" do
    expect { client.post }
      .not_to send_request_to(client)
      .with(protocol: :http)
  end

  it "matches port inline" do
    expect { client.port(443).post }
      .to send_request_to(client)
      .with(port: 443)
  end

  it "ignores wrong port" do
    expect { client.port(443).post }
      .not_to send_request_to(client)
      .with(port: 89)
  end

  it "matches type inline" do
    expect { client.post }
      .to send_request_to(client)
      .with(type: 'POST')
  end

  it "ignores wrong type" do
    expect { client.get }
      .not_to send_request_to(client)
      .with(type: 'POST')
  end

  it "matches path inline" do
    expect { client.path(:bar).post }
      .to send_request_to(client)
      .with(path: "/foo/bar")
  end

  it "ignores wrong path" do
    expect { client.post }
      .not_to send_request_to(client)
      .with(path: "/foo/bar")
  end

  it "matches query inline" do
    expect { client.query(bar: :bar).post }
      .to send_request_to(client)
      .with(query: { bar: :bar })
  end

  it "ignores wrong query" do
    expect { client.query(bar: :bar, foo: :foo).post }
      .not_to send_request_to(client)
      .with(query: { bar: :bar })
  end

  it "matches body inline" do
    expect { client.body(bar: :bar).post }
      .to send_request_to(client)
      .with(body: { bar: :bar })
  end

  it "ignores wrong body" do
    expect { client.body(bar: :bar, foo: :foo).post }
      .not_to send_request_to(client)
      .with(body: { bar: :bar })
  end

  it "matches headers inline" do
    expect { client.headers('X-Bar' => :Bar).post }
      .to send_request_to(client)
      .with(headers: { 'X-Bar' => :Bar })
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
