describe "sending get request", :fake_api do
  subject { client.users[1].sms.get! params }

  let(:client)  { Evil::Client.with base_url: "http://example.com/" }
  let(:params)  { { value: 1 } }
  let(:request) { a_request(:get, "http://example.com/users/1/sms?value=1") }
  let(:status)  { [200, "Ok"] }
  let(:body)    { nil }

  before do
    stub_request(:get, %r{example.com/users/1/sms})
      .to_return(status: status, body: body, headers: {})
  end

  it "sends a proper request" do
    subject
    expect(request).to have_been_made
  end

  it "defines JSON type in headers" do
    subject
    expect(request).to have_been_made_with_headers(
      "Accept"       => "application/json",
      "Content-Type" => "application/json; charset=utf-8",
    )
  end

  it "ignores request_id when it hasn't been set" do
    subject
    expect(request).not_to have_been_made_with_header "X-Request-Id"
  end

  it "takes request id from Rack via RequestID using key 'HTTP_X_REQUEST_ID'" do
    rack_app = proc { |_env| subject }
    rack_env = { 'HTTP_X_REQUEST_ID' => "foo" }
    Evil::Client::RequestID.new(rack_app).call(rack_env)

    expect(request).to have_been_made_with_headers "X-Request-Id" => "foo"
  end

  context "when server responded with success" do
    let(:status)  { [200, "Ok"] }
    let(:body)    { "{\"id\":1,\"text\":\"Hello\"}" }

    it "deserializes response body to hashie" do
      expect(subject.id).to   eql 1
      expect(subject.text).to eql "Hello"
    end
  end

  context "when server responded without body" do
    let(:status) { [200, "Ok"] }
    let(:body)   { nil }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "when server responded with error and no handler was provided" do
    let(:status) { [404, "Not found"] }
    let(:body)   { nil }

    it "raises ResponseError with error status" do
      expect { subject }.to raise_error do |error|
        expect(error).to be_kind_of Evil::Client::Errors::ResponseError
        expect(error.status).to eql 404
      end
    end

    it "stores the raw HTTP::Message response in exception" do
      expect { subject }.to raise_error do |error|
        response = error.response
        expect(response.status).to eql 404
        expect(response.reason).to eql "Not found"
      end
    end

    it "raises error with #status, #request, and #response" do
      expect { subject }.to raise_error do |error|
        expect(error.status).to eql 404
        expect(error).to respond_to :request
        expect(error).to respond_to :response
      end
    end
  end

  context "when server responded with error and block handler was provided" do
    subject { client.users[1].sms.get!(params, &handler) }

    let(:status)  { [404, "Not found"] }
    let(:body)    { nil }
    let(:handler) { proc { |response| [response.status, response.content] } }

    it "sends raw response to the handler and returns the result" do
      expect(subject).to eql [404, ""]
    end
  end
end
