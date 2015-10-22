describe Evil::Client::Errors::URLError do
  let(:error) { described_class.new :wrong }

  describe ".new" do
    subject { error }

    it { is_expected.to be_kind_of ::RuntimeError }
  end

  describe "#message" do
    subject { error.message }

    it "returns a proper message" do
      expect(subject)
        .to eql "Invalid URL 'wrong'. Both protocol and host must be defined."
    end
  end

  describe "#url" do
    subject { error.url }

    it { is_expected.to eql "wrong" }
  end
end
