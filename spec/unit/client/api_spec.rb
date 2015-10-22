describe Evil::Client::API do
  let(:api)      { described_class.new base_url: base_url }
  let(:base_url) { "127.0.0.1/v1" }

  describe "#base_url" do
    subject { api.base_url }

    it { is_expected.to eql base_url }
  end

  describe "#url" do
    subject { api.url(address) }

    let(:address) { "users/1/sms" }

    it { is_expected.to eql "127.0.0.1/v1/users/1/sms" }
  end
end
