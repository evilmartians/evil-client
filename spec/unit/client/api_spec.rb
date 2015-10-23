describe Evil::Client::API do

  let(:klass)    { Class.new(described_class) }
  let(:api)      { klass.new settings }
  let(:settings) { { base_url: base_url, request_id: "foobar" } }
  let(:base_url) { "http://127.0.0.1/v1" }

  describe ".id_provider=" do
    subject { klass.id_provider = provider }
    let(:provider) { double :provider, value: "foobar" }

    it "sets provider for default id" do
      expect { subject }
        .to change { klass.default_id }
        .to "foobar"
    end
  end

  describe ".new" do
    subject { api }

    context "without protocol in base url" do
      let(:base_url) { "127.0.0.1" }

      it "fails" do
        expect { subject }.to raise_error \
          Evil::Client::Errors::URLError, /'127\.0\.0\.1'/
      end
    end

    context "without host in base url" do
      let(:base_url) { "http://" }

      it "fails" do
        expect { subject }.to raise_error \
          Evil::Client::Errors::URLError, %r{'http://'}
      end
    end

    context "without request_id" do
      before { settings.delete :request_id }

      it "fails" do
        expect { subject }.to raise_error Evil::Client::Errors::RequestIDError
      end
    end
  end

  describe "#base_url" do
    subject { api.base_url }

    it { is_expected.to eql base_url }
  end

  describe "#request_id" do
    subject { api.request_id }

    it { is_expected.to eql "foobar" }

    context "from default_id" do
      before do
        allow(klass).to receive(:default_id) { "foobar" }
        settings.delete :request_id
      end

      it { is_expected.to eql "foobar" }
    end
  end

  describe "#uri" do
    subject { api.uri(urn) }

    let(:urn) { "users/1/sms" }

    it { is_expected.to eql "http://127.0.0.1/v1/users/1/sms" }
  end

  describe "#adapter" do
    before  { klass.logger = logger }
    subject { api.adapter }

    let(:logger) { double :logger }

    it "builds JSONClient" do
      expect(subject).to be_kind_of JSONClient
    end

    it "sets base_url" do
      expect(subject.base_url).to eql base_url
    end

    it "assigns current logger" do
      expect(subject.debug_dev).to eql logger
    end
  end
end
