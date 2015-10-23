describe Evil::Client::Path do

  let(:path) { described_class.new }

  # Instance methods

  describe "#finalize!" do
    subject { path.finalize! }

    it { is_expected.to eql "" }

    context "when parts are set" do
      let(:path) { described_class.new %w(foo bar baz) }

      it { is_expected.to eql "foo/bar/baz" }
    end
  end

  describe "#call" do
    subject { path.call(:foo).call(1) }

    it "creates new instance" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql path
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo/1"
    end
  end

  describe "#[]" do
    subject { path[:foo][1] }

    it "creates new instance" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql path
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo/1"
    end
  end

  describe "#call!" do
    subject { path.send(:call!, :foo).send(:call!, 1) }

    it "returns the same instance" do
      expect(subject).to eql path
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo/1"
    end
  end

  describe "#method_missing" do
    subject { path.foo.bar.baz }

    it "creates updated path" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql path
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "foo/bar/baz"
    end

    context "with bang" do
      subject { path.foo! }

      it "fails" do
        expect { subject }.to raise_error NoMethodError
      end
    end

    context "with arguments" do
      subject { path.foo :bar }

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

    it "instantiates path" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.finalize!).to eql "1"
    end
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
    subject { described_class.foo }

    it "instantiates path" do
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
