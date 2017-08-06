RSpec.describe Evil::Client::TypeError do
  let(:error) { described_class.new name, type }

  describe ".check!" do
    subject { described_class.check! schema, name, type }

    let(:schema) { double operations: { foo: double }, scopes: { bar: double } }

    context "with unused name" do
      let(:name) { :qux }
      let(:type) { :operation }

      it { is_expected.to be_nil }
    end

    context "with valid name for operation" do
      let(:name) { :foo }
      let(:type) { :operation }

      it { is_expected.to be_nil }
    end

    context "with valid name for scope" do
      let(:name) { :bar }
      let(:type) { :scope }

      it { is_expected.to be_nil }
    end

    context "with invalid name for operation" do
      let(:name) { :bar }
      let(:type) { :operation }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end

    context "with invalid name for scope" do
      let(:name) { :foo }
      let(:type) { :scope }

      it "raises itself" do
        expect { subject }.to raise_error described_class
      end
    end
  end

  describe "#message" do
    subject { error.message }
    let(:name) { "foo" }

    context "for a scope" do
      let(:type) { :scope }

      it "builds a proper error message" do
        expect(subject).to eq "The operation :foo was already defined." \
                              " You cannot create scope with the same name."
      end
    end

    context "for an operation" do
      let(:type) { :operation }

      it "builds a proper error message" do
        expect(subject).to eq "The scope :foo was already defined." \
                              " You cannot create operation with the same name."
      end
    end
  end
end
