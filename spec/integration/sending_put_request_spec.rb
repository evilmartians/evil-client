describe "sending put request", :fake_api do
  subject { client.users[1].sms.put! params }

  let(:client)  { Evil::Client.with base_url: "http://example.com/" }
  let(:params)  { { text: "Hello", request_id: "foobar" } }
  let(:request) do
    a_request(:post, "http://example.com/users/1/sms")
      .with(
        headers: {
          "Accept"       => "application/json",
          "Content-Type" => "application/json; charset=utf-8",
          "X-Request-Id" => "foobar"
        },
        body: "text=Hello&_method=put"
      )
  end

  before do
    stub_request(:post, %r{example.com/users/1/sms})
      .to_return(status: status, body: body, headers: {})
  end

  context "when server responded with success" do
    let(:status) { [200, "Ok"] }
    let(:body)   { "{\"id\":1,\"text\":\"Hello\"}" }

    it "sends a proper request" do
      subject
      expect(request).to have_been_made
    end

    it "deserializes response body to hashie" do
      expect(subject.id).to   eql 1
      expect(subject.text).to eql "Hello"
    end
  end

  context "when server responded without body" do
    let(:status) { [304, "Not changed"] }
    let(:body)   { nil }

    it "returns nil" do
      expect(subject).to eq ""
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

    it "stores the original Evil::Client::Request request in exception" do
      expect { subject }.to raise_error do |error|
        expect(error.request.to_a).to eql [
          "post",
          "http://example.com/users/1/sms",
          body: {
            _method: "put",
            text: "Hello"
          },
          header: {
            "Accept"       => "application/json",
            "Content-Type" => "application/json; charset=utf-8",
            "X-Request-Id" => "foobar"
          }
        ]
      end
    end
  end

  context "when server responded with error and block handler was provided" do
    subject { client.users[1].sms.put!(params) { |res| res.status } }

    let(:status) { [404, "Not found"] }
    let(:body)   { nil }

    it "returns block result" do
      expect(subject).to eql 404
    end
  end

  context "when no request_id was provided by request" do
    before { params.delete :request_id }

    let(:status) { [200, "Ok"] }
    let(:body)   { nil }

    it "raises RequestIDError" do
      expect { subject }.to raise_error Evil::Client::Errors::RequestIDError
    end
  end
end
