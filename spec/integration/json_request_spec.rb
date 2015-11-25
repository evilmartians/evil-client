describe "request", :fake_api do

  subject do
    stub_request :any, /localhost/
    client.post params
    a_request(:post, "http://localhost")
  end

  let(:client) { Evil::Client.with(base_url: "http://localhost").in_json }
  let(:params) { { foo: { bar: :baz } } }
  let(:body)   { '{"foo":{"bar":"baz"}}' }

  it "uses proper headers" do
    expect(subject).to have_been_made_with_headers(
      "Content-Type" => "application/json; charset=utf-8",
      "Accept"       => "application/json"
    )
  end

  it "uses proper body" do
    expect(subject).to have_been_made_with_body(body)
  end
end
