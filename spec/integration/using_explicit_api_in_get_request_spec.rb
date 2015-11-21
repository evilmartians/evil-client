describe "using explicit API in get request", :fake_api do
  subject do
    stub_request(:get, %r{example.com/users/1/sms})
    client
      .with_path(:users, 1, :sms)
      .with_query(key: :foo)
      .with_headers("Front-End-Https" => "on")
      .get! params
  end

  let(:client)  { Evil::Client.with base_url: "http://example.com/" }
  let(:params)  { { text: "Hello" } }
  let(:request) do
    a_request(:get, "http://example.com/users/1/sms?key=foo&text=Hello")
  end

  it "uses query from request params" do
    subject
    expect(request).to have_been_made
  end

  it "uses default headers" do
    subject
    expect(request).to have_been_made_with_headers(
      "Accept"       => "application/json",
      "Content-Type" => "application/json; charset=utf-8"
    )
  end

  it "takes request id from Rack via RequestID using key 'HTTP_X_REQUEST_ID'" do
    rack_app = proc { |_env| subject }
    rack_env = { "HTTP_X_REQUEST_ID" => "foo" }
    Evil::Client::RequestID.new(rack_app).call(rack_env)

    expect(request).to have_been_made_with_headers("X-Request-Id" => "foo")
  end

  it "uses explicit headers" do
    subject
    expect(request).to have_been_made_with_headers("Front-End-Https" => "on")
  end
end
