describe Evil::Client::URL do

  let(:uri) { described_class.new }

  describe "#call!" do
    subject { uri.call! }

    it "returns current address" do
      expect(subject).to eql ""
    end
  end # describe #call!

  describe "#call" do
    subject { uri.call(:foo).call(1) }

    it "creates updated uri" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql uri
    end

    it "adds part to path" do
      expect(subject.call!).to eql "foo/1"
    end
  end # describe #call

  describe "arbitrary instance method" do
    subject { uri.foo.bar.baz }

    it "creates updated uri" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql uri
    end

    it "adds part to path" do
      expect(subject.call!).to eql "foo/bar/baz"
    end
  end # describe arbitrary instance method

  describe "#respond_to?" do
    context "method defined in superclass" do
      subject { uri.respond_to? :class }

      it { is_expected.to eql true }
    end

    context "undefined method without special symbols" do
      subject { uri.respond_to? "foo_123" }

      it { is_expected.to eql true }
    end

    context "undefined method with bang" do
      subject { uri.respond_to? "foo!" }

      it { is_expected.to eql false }
    end

    context "undefined method with question" do
      subject { uri.respond_to? "foo?" }

      it { is_expected.to eql false }
    end
  end # describe #respond_to?

  describe "arbitrary class method" do
    subject { described_class.foo }

    it "instantiates uri" do
      expect(subject).to be_kind_of described_class
    end

    it "adds part to path" do
      expect(subject.call!).to eql "foo"
    end
  end # describe arbitrary instance method

  describe ".respond_to?" do
    context "method defined in superclass" do
      subject { uri.respond_to? :superclass }

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
  end # describe .respond_to?

end # describe Evil::Client::URL
