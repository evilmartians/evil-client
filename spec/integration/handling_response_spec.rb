describe "handling response", :fake_api do
  let(:client)  { Evil::Client.with(base_url: "http://localhost") }
  let(:request) { a_request(:get, "http://localhost") }
  let(:status)  { [200, "Ok"] }
  let(:body)    { nil }

  before do
    stub_request(:any, %r{localhost})
      .to_return(status: status, body: body, headers: {})
  end

  subject { client.get }

  context "with success" do
    let(:status)  { [200, "Ok"] }
    let(:body)    { "{\"id\":1,\"text\":\"Hello\"}" }

    it "deserializes response body to hashie" do
      expect(subject.id).to   eql 1
      expect(subject.text).to eql "Hello"
    end
  end

  context "without body" do
    let(:status) { [204, "Ok"] }
    let(:body)   { nil }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "with error and no handler was provided" do
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

  context "with error and block handler was provided" do
    subject { client.get(&handler) }

    let(:status)  { [404, "Not found"] }
    let(:body)    { nil }
    let(:handler) { proc { |response| [response.status, response.content] } }

    it "sends raw response to the handler and returns the result" do
      expect(subject).to eql [404, ""]
    end
  end
end
