describe Evil::Client::Errors::RequestIDError do
  let(:error) { described_class.new }

  describe ".new" do
    subject { error }

    it { is_expected.to be_kind_of ::RuntimeError }
  end

  describe "#message" do
    subject { error.message }

    it "returns a proper message" do
      expect(subject).to eql \
        "Request ID should be set for API. Either use Rails, or set it manually"
    end
  end
end
