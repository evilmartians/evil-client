describe "trying get request", :fake_api do
  subject { client.users[1].sms.try_get! params }

  let(:client)  { Evil::Client.with base_url: "http://example.com/" }
  let(:params)  { { visible: true, request_id: "foobar" } }
  let(:request) do
    a_request(:get, "http://example.com/users/1/sms?visible=true")
      .with(headers: {
        "Accept"       => "application/json",
        "Content-Type" => "application/json; charset=utf-8",
        "X-Request-Id" => "foobar"
      })
  end

  before do
    stub_request(:get, %r{example.com/users/1/sms})
      .to_return(status: status, body: body, headers: {})
  end

  context "when server responded with success" do
    let(:status) { [200, "Ok"] }
    let(:body)   { "{\"id\":1,\"text\":\"Hello!\"}" }

    it "sends a proper request" do
      subject
      expect(request).to have_been_made
    end

    it "deserializes response body to hashie" do
      expect(subject.id).to   eql 1
      expect(subject.text).to eql "Hello!"
    end
  end

  context "when server responded without body" do
    let(:status) { [200, "Ok"] }
    let(:body)   { nil }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "when server responded with error" do
    subject { client.users[1].sms.try_get!(params) }

    let(:status) { [404, "Not found"] }
    let(:body)   { nil }

    it "returns false" do
      expect(subject).to eql false
    end
  end
end
