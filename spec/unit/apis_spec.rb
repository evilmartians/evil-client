describe Evil::Client::APIs do
  let(:apis) { described_class.new api }
  let(:api)  { double :api, url: "127.0.0.1/v1/users/1/sms" }

  before { allow(Evil::Client::API).to receive(:new) { api } }

  describe "#each" do
    context "with a block" do
      subject { apis.to_a }

      it "iterates by api" do
        expect(subject).to eql [api]
      end
    end

    context "without a block" do
      subject { apis.each }

      it "returns enumerator" do
        expect(subject).to be_kind_of Enumerator
        expect(subject.to_a).to eql [api]
      end
    end
  end # describe #each

  describe "#url" do
    subject { apis.url "users/1/sms" }

    it "forwards call to api" do
      expect(api).to receive(:url).with "users/1/sms"
      expect(subject).to eql "127.0.0.1/v1/users/1/sms"
    end

    context "when no api specified" do
      let(:apis) { described_class.new }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, %r{users/1/sms}
      end
    end

    context "when api doesn't resolve url" do
      let(:api) { double :api, url: nil }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, %r{users/1/sms}
      end
    end
  end # describe #url

  describe ".with" do
    subject { described_class.with options }

    let(:options) { { base_url: "127.0.0.1/v1" } }

    it "builds and wraps api with options given" do
      expect(Evil::Client::API).to receive(:new).with(options)
      expect(subject).to be_kind_of described_class
      expect(subject.to_a).to eql [api]
    end
  end # describe .with
end # describe Evil::Client::APIs
