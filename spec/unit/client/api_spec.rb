describe Evil::Client::API do
  let(:api)      { described_class.new base_url: base_url }
  let(:base_url) { "http://127.0.0.1/v1" }

  describe ".new" do
    subject { api }

    context "without protocol in base url" do
      let(:base_url) { "127.0.0.1" }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, /'127\.0\.0\.1'/
      end
    end

    context "without host in base url" do
      let(:base_url) { "http://" }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, %r{'http://'}
      end
    end
  end

  describe "#base_url" do
    subject { api.base_url }

    it { is_expected.to eql base_url }
  end

  describe "#uri" do
    subject { api.uri(urn) }

    let(:urn) { "users/1/sms" }

    it { is_expected.to eql "http://127.0.0.1/v1/users/1/sms" }
  end

  describe "#uri?" do
    subject { api.uri?(urn) }

    let(:urn) { "users/1/sms" }

    it { is_expected.to eql true }
  end
end
