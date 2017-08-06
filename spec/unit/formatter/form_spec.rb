RSpec.describe Evil::Client::Formatter::Form do
  subject { described_class.call value }

  context "when value is a hash" do
    let(:value) { { foo: { bar: [baz: :qux], qux: [1, 2] } } }

    it "returns formatted string" do
      expect(subject).to eq "foo[bar][][baz]=qux&foo[qux][]=1&foo[qux][]=2"
    end
  end

  context "when value is nil" do
    let(:value) { nil }

    it "returns nil" do
      expect(subject).to be_nil
    end
  end

  context "when value is not a hash" do
    let(:value) { 844 }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }.to raise_error StandardError, "844 is not a hash"
    end
  end
end
