describe "safe response", :fake_api do
  subject { Evil::Client.with(base_url: "http://localhost").get }

  before do
    stub_request(:any, /localhost/)
      .to_return(status: status, headers: {}, body: body)
  end

  context "with success" do
    let(:status) { [200, "Ok"] }
    let(:body)   { "{\"id\":1,\"text\":\"Hello\"}" }

    it "deserializes response body to success hashie" do
      expect(subject.id).to   eql 1
      expect(subject.text).to eql "Hello"
      expect(subject).not_to be_error
    end
  end

  context "without body" do
    let(:status) { [204, "Ok"] }
    let(:body)   { nil }

    it "returns empty hashie" do
      expect(subject).to be_kind_of Hashie::Mash
      expect(subject).to be_empty
    end
  end

  context "with non-json body" do
    let(:status) { [200, "Ok"] }
    let(:body)   { "Bang!" }

    it "fails" do
      expect { subject }.to raise_error(StandardError, /'Bang!'/)
    end
  end

  context "with error and json body" do
    let(:status) { [404, "Not found"] }
    let(:body)   { "{\"text\":\"Bang!\"}" }

    it "returns error hashie" do
      expect(subject).to be_error
      expect(subject.text).to eql "Bang!"
      expect(subject.meta.http_code).to eql 404
    end
  end

  context "with error and non-json body" do
    let(:status) { [404, "Not found"] }
    let(:body)   { "Bang!" }

    it "returns error hashie" do
      expect(subject.error).to eql "Bang!"
      expect(subject.meta.http_code).to eql 404
    end
  end

  context "with error and empty body" do
    let(:status) { [404, "Not found"] }
    let(:body)   { nil }

    it "returns error hashie" do
      expect(subject).to be_error
      expect(subject.error).to be_empty
      expect(subject.meta.http_code).to eql 404
    end
  end
end
