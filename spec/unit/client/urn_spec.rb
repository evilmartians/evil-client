describe Evil::Client::URN do

  let(:urn) { described_class.new }

  # Instance methods

  describe "#finalize!" do
    subject { urn.finalize! }

    it { is_expected.to eql "" }

    context "when parts are set" do
      let(:urn) { described_class.new %w(foo bar baz) }

      it { is_expected.to eql "foo/bar/baz" }
    end
  end

  describe "#call" do
    subject { urn.call(:foo).call(1) }

    it "creates new instance" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql urn
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo/1"
    end
  end

  describe "#call!" do
    subject { urn.send(:call!, :foo).send(:call!, 1) }

    it "returns the same instance" do
      expect(subject).to eql urn
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo/1"
    end
  end # describe #call!

  describe "#method_missing" do
    subject { urn.foo.bar.baz }

    it "creates updated urn" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql urn
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo/bar/baz"
    end

    context "with bang" do
      subject { urn.foo! }

      it "fails" do
        expect { subject }.to raise_error NoMethodError
      end
    end

    context "with arguments" do
      subject { urn.foo :bar }

      it "fails" do
        expect { subject }.to raise_error NoMethodError
      end
    end
  end

  describe "#respond_to?" do
    subject { urn.respond_to? name }

    context "method defined in superclass" do
      let(:name) { :class }

      it { is_expected.to eql true }
    end

    context "undefined method without special symbols" do
      let(:name) { :foo_123 }

      it { is_expected.to eql true }
    end

    context "undefined method with bang" do
      let(:name) { :foo! }

      it { is_expected.to eql false }
    end

    context "undefined method with question" do
      let(:name) { :foo? }

      it { is_expected.to eql false }
    end
  end

  # Class methods

  describe ".finalize!" do
    subject { described_class.finalize! }

    it { is_expected.to eql "" }
  end

  describe ".call" do
    subject { described_class.call(1) }

    it "instantiates urn" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "1"
    end
  end

  describe ".method_missing" do
    subject { described_class.foo }

    it "instantiates urn" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo"
    end
  end

  describe ".respond_to?" do
    subject { described_class.respond_to? name }

    context "method defined in superclass" do
      let(:name) { :superclass }

      it { is_expected.to eql true }
    end

    context "undefined method without special symbols" do
      let(:name) { :foo_123 }

      it { is_expected.to eql true }
    end

    context "instance method with bang" do
      let(:name) { :finalize! }

      it { is_expected.to eql true }
    end

    context "undefined method with bang" do
      let(:name) { :foo_123! }

      it { is_expected.to eql false }
    end
  end
end
