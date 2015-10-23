describe Evil::Client::Path do

  let(:path) { described_class.new }

  # Instance methods

  describe "#finalize!" do
    subject { path.finalize! }

    it { is_expected.to eql "" }

    context "when parts are set" do
      let(:path) { described_class.new %w(call bar baz) }

      it { is_expected.to eql "call/bar/baz" }
    end
  end

  describe "#[]" do
    subject { path[:call][1] }

    it "creates new instance" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql path
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "call/1"
    end
  end

  describe "#method_missing" do
    subject { path.call.bar.baz }

    it "creates updated path" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql path
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "call/bar/baz"
    end

    context "with bang" do
      subject { path.call! }

      it "fails" do
        expect { subject }.to raise_error NoMethodError
      end
    end

    context "with arguments" do
      subject { path.call :bar }

      it "fails" do
        expect { subject }.to raise_error NoMethodError
      end
    end
  end

  describe "#respond_to?" do
    subject { path.respond_to? name }

    context "method defined in superclass" do
      let(:name) { :class }

      it { is_expected.to eql true }
    end

    context "undefined method without special symbols" do
      let(:name) { :call_123 }

      it { is_expected.to eql true }
    end

    context "undefined method with bang" do
      let(:name) { :call! }

      it { is_expected.to eql false }
    end

    context "undefined method with question" do
      let(:name) { :call? }

      it { is_expected.to eql false }
    end
  end

  # Class methods

  describe ".finalize!" do
    subject { described_class.finalize! }

    it { is_expected.to eql "" }
  end

  describe ".[]" do
    subject { described_class[1] }

    it "instantiates path" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "1"
    end
  end

  describe ".method_missing" do
    subject { described_class.call }

    it "instantiates path" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "call"
    end
  end

  describe ".respond_to?" do
    subject { described_class.respond_to? name }

    context "method defined in superclass" do
      let(:name) { :superclass }

      it { is_expected.to eql true }
    end

    context "undefined method without special symbols" do
      let(:name) { :call_123 }

      it { is_expected.to eql true }
    end

    context "instance method with bang" do
      let(:name) { :finalize! }

      it { is_expected.to eql true }
    end

    context "undefined method with bang" do
      let(:name) { :call_123! }

      it { is_expected.to eql false }
    end
  end
end
