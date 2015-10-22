describe Evil::Client::Errors::URNError do
  let(:error) { described_class.new :"unknown/address" }

  describe ".new" do
    subject { error }

    it { is_expected.to be_kind_of ::RuntimeError }
  end

  describe "#message" do
    subject { error.message }

    it "returns a proper message" do
      expect(subject)
        .to eql "The URN 'unknown/address' cannot be resolved to URI"
    end
  end

  describe "#urn" do
    subject { error.urn }

    it { is_expected.to eql "unknown/address" }
  end
end
