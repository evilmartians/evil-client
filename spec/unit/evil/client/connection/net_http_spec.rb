require "evil/client/connection/net_http"

describe Evil::Client::Connection::NetHTTP do
  let(:uri)        { URI("https://example.com/foo/") }
  let(:connection) { described_class.new(uri) }
  let(:env) do
    {
      http_method:  "post",
      path:         "bar/baz",
      headers:      { "Content-Type": "text/plain", "Accept": "text/plain" },
      body_string:  "Check!",
      query_string: "status=new"
    }
  end

  before do
    stub_request(:post, "https://example.com/foo/bar/baz?status=new")
      .to_return status:  201,
                 body:    "Success!",
                 headers: { "Content-Type" => "text/plain; charset: utf-8" }
  end

  subject { connection.call env }

  it "sends a request" do
    subject
    expect(a_request(:post, "https://example.com/foo/bar/baz?status=new"))
      .to have_been_made
  end

  it "returns rack-compatible response" do
    expect(subject).to eq [
      201,
      { "content-type" => ["text/plain; charset: utf-8"] },
      ["Success!"]
    ]
  end
end
