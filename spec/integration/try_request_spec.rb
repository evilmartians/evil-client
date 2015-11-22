describe "try request", :fake_api do
  subject { Evil::Client.with(base_url: "http://localhost").try_get }

  before do
    stub_request(:any, %r{localhost})
      .to_return(status: status, headers: {}, body: body)
  end

  context "when server responded with success" do
    let(:status) { [200, "Ok"] }
    let(:body)   { "{\"id\":1,\"text\":\"Hello\"}" }

    it "deserializes response body to hashie" do
      expect(subject.id).to   eql 1
      expect(subject.text).to eql "Hello"
    end
  end

  context "when server responded without body" do
    let(:status) { [204, "Ok"] }
    let(:body)   { nil }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "when server responded with error" do
    let(:status) { [404, "Not found"] }
    let(:body)   { nil }

    it "returns false" do
      expect(subject).to eql false
    end
  end
end
