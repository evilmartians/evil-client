RSpec.describe Evil::Client::Options do
  let(:options) { described_class.new source }
  let(:source)  { { foo: :FOO, bar: :BAR, baz: :BAZ } }

  describe "#slice" do
    subject { source.slice :foo, :baz }

    it "slices keys from a hash" do
      expect(subject).to eq foo: :FOO, baz: :BAZ
    end
  end

  describe "#except" do
    subject { source.except :foo, :baz }

    it "removes keys from a hash" do
      expect(subject).to eq bar: :BAR
    end
  end
end
