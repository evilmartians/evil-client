describe Evil::Client::URL do

  let(:url) { described_class.new }

  # Instance methods

  describe "#url!" do
    subject { url.url! }

    it { is_expected.to eql "" }

    context "when parts are set" do
      let(:url) { described_class.new %w(foo bar baz) }

      it { is_expected.to eql "foo/bar/baz" }
    end
  end

  describe "#call" do
    subject { url.call(:foo).call(1) }

    it "creates new instance" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql url
    end

    it "adds part to path" do
      expect(subject.url!).to eql "foo/1"
    end
  end

  describe "#call!" do
    subject { url.send(:call!, :foo).send(:call!, 1) }

    it "returns the same instance" do
      expect(subject).to eql url
    end

    it "adds part to path" do
      expect(subject.url!).to eql "foo/1"
    end
  end # describe #call!

  describe "#method_missing" do
    subject { url.foo.bar.baz }

    it "creates updated url" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql url
    end

    it "adds part to path" do
      expect(subject.url!).to eql "foo/bar/baz"
    end

    context "with bang" do
      subject { url.foo! }

      it "fails" do
        expect { subject }.to raise_error NoMethodError
      end
    end

    context "with arguments" do
      subject { url.foo :bar }

      it "fails" do
        expect { subject }.to raise_error NoMethodError
      end
    end
  end

  describe "#respond_to?" do
    context "method defined in superclass" do
      subject { url.respond_to? :class }

      it { is_expected.to eql true }
    end

    context "undefined method without special symbols" do
      subject { url.respond_to? "foo_123" }

      it { is_expected.to eql true }
    end

    context "undefined method with bang" do
      subject { url.respond_to? "foo!" }

      it { is_expected.to eql false }
    end

    context "undefined method with question" do
      subject { url.respond_to? "foo?" }

      it { is_expected.to eql false }
    end
  end

  # Class methods

  describe ".url!" do
    subject { described_class.url! }

    it { is_expected.to eql "" }
  end

  describe ".call" do
    subject { described_class.call(1) }

    it "instantiates url" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.url!).to eql "1"
    end
  end

  describe ".method_missing" do
    subject { described_class.foo }

    it "instantiates url" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.url!).to eql "foo"
    end
  end

  describe ".respond_to?" do
    context "method defined in superclass" do
      subject { url.respond_to? :superclass }

      it { is_expected.to eql true }
    end

    context "undefined method without special symbols" do
      subject { described_class.respond_to? "foo_123" }

      it { is_expected.to eql true }
    end

    context "undefined method with bang" do
      subject { described_class.respond_to? "foo!" }

      it { is_expected.to eql false }
    end

    context "undefined method with question" do
      subject { described_class.respond_to? "foo?" }

      it { is_expected.to eql false }
    end
  end
end
