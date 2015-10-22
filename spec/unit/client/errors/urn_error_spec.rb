describe Evil::Client::Errors::URNError do
  let(:error) { described_class.new :"unknown/address" }

  describe ".new" do
    subject { error }

    it { is_expected.to be_kind_of ::RuntimeError }
  end

  describe "#message" do
    subject { error.message }

    it "returns message for all APIs" do
      expect(subject).to eql "No API can resolve 'unknown/address' to URI"
    end

    context "with one API name" do
      let(:error) { described_class.new :"unknown/address", [:default] }

      it "returns message for specified API" do
        expect(subject)
          .to eql "API :default cannot resolve 'unknown/address' to URI"
      end
    end

    context "with several API name" do
      let(:error) { described_class.new :"unknown/address", [:users, :sms] }

      it "returns message for specified API" do
        expect(subject)
          .to eql "APIs: :users, :sms cannot resolve 'unknown/address' to URI"
      end
    end
  end

  describe "#urn" do
    subject { error.urn }

    it { is_expected.to eql "unknown/address" }
  end
end
