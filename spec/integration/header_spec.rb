describe "header", :fake_api do
  before { stub_request(:get, %r{localhost}) }

  let(:request) { a_request(:get, "http://localhost") }
  subject do
    Evil::Client
      .with(base_url: "http://localhost/")
      .headers("Foo" => :bar)
      .headers("Bar" => :baz)
      .get!
  end

  it "includes default headers" do
    subject
    expect(request).to have_been_made_with_headers(
      "Accept"       => "application/json",
      "Content-Type" => "application/json; charset=utf-8"
    )
  end

  it "includes explicit headers" do
    subject
    expect(request).to have_been_made_with_headers(
      "Foo" => "bar",
      "Bar" => "baz"
    )
  end

  it "takes request id from middleware" do
    rack_app = proc { |_env| subject }
    rack_env = { "HTTP_X_REQUEST_ID" => "foo" }
    Evil::Client::RequestID.new(rack_app).call(rack_env)

    expect(request).to have_been_made_with_headers(
      "X-Request-Id" => "foo"
    )
  end

  it "skips request id by default" do
    subject
    expect(request).not_to have_been_made_with_header "X-Request-Id"
  end
end
