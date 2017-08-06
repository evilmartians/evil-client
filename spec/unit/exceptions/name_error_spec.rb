RSpec.describe Evil::Client::NameError do
  let(:error)     { described_class.new name, forbidden }
  let(:name)      { "foo" }
  let(:forbidden) { %i[foo bar] }

  describe ".check!" do
    subject { described_class.check! name, forbidden }

    context "with a valid name" do
      let(:name) { "qux_3" }

      it "symbolizes the name" do
        expect(subject).to eq :qux_3
      end
    end

    context "with a name starting from a digit" do
      let(:name) { "1qux_3" }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end

    context "with a name starting from  underscore" do
      let(:name) { "_qux_3" }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end

    context "with a one-letter name" do
      let(:name) { "q" }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end

    context "with a name ending with the underscore" do
      let(:name) { "qux_3_" }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end

    context "with a name containing improper symbols" do
      let(:name) { "quX_3" }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end

    context "with a forbidden name" do
      let(:name) { "foo" }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end
  end

  describe "#message" do
    subject { error.message }

    it "builds a proper error message" do
      expect(subject).to eq "Invalid name :foo." \
        " It should contain latin letters in the lower case," \
        " digits, and underscores only; have minimum 2 chars;" \
        " start from a letter; end with either letter or digit." \
        " The following names: 'foo', 'bar' are already used by Evil::Client."
    end
  end
end
