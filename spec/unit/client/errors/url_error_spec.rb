describe Evil::Client::Errors::URLError do
  let(:error) { described_class.new :"unknown/address" }

  describe ".new" do
    subject { error }

    it { is_expected.to be_kind_of ::RuntimeError }
  end

  describe "#message" do
    subject { error.message }

    it "returns a proper message" do
      expect(subject)
        .to eql "The address 'unknown/address' cannot be resolved to url"
    end
  end

  describe "#address" do
    subject { error.address }

    it { is_expected.to eql "unknown/address" }
  end
end
