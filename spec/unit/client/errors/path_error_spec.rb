describe Evil::Client::Errors::PathError do
  let(:error) { described_class.new :"unknown/address" }

  describe ".new" do
    subject { error }

    it { is_expected.to be_kind_of ::RuntimeError }
  end

  describe "#message" do
    subject { error.message }

    it { is_expected.to eql "Path 'unknown/address' cannot be resolved to URI" }
  end
end
