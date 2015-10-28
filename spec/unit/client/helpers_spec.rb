describe Evil::Client::Helpers do
  describe ".hashify" do
    subject { described_class.hashify(data) }

    let(:data) { [foo: :bar, bar: [{ foo: { baz: 1 } }]] }

    it "serializes data correctly" do
      expect(subject.first.foo).to eql :bar
      expect(subject.first.bar.first.foo.baz).to eql 1
    end
  end
end
