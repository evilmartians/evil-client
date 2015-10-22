describe Evil::Client::API do
  let(:api)      { described_class.new base_url: base_url }
  let(:base_url) { "127.0.0.1/v1" }

  describe "#base_url" do
    subject { api.base_url }

    it { is_expected.to eql base_url }
  end

  describe "#uri" do
    subject { api.uri(urn) }

    let(:urn) { "users/1/sms" }

    it { is_expected.to eql "127.0.0.1/v1/users/1/sms" }
  end

  describe "#uri?" do
    subject { api.uri?(urn) }

    let(:urn) { "users/1/sms" }

    it { is_expected.to eql true }
  end
end
