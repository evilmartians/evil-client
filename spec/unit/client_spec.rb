describe Evil::Client do

  let(:client) { described_class.with base_url: "http://localhost/v1" }

  describe ".with" do
    subject { client }

    it "instantiates the client" do
      expect(subject).to be_kind_of described_class
    end

    it "sets base_url to the only used API" do
      expect(subject.uri!).to eql "http://localhost/v1/"
    end
  end

  describe "#uri!" do
    it "returns base_url by default" do
      expect(client.uri!).to eql "http://localhost/v1/"
    end

    it "returns current uri after modification" do
      expect(client.foo[1].bar.uri!)
        .to eql "http://localhost/v1/foo/1/bar"
    end
  end

  describe "#method_missing" do
    subject { client.foo[1].bar }

    it "returns new client instance" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql client
    end

    it "adds parts to uri" do
      expect(subject.uri!).to eql "http://localhost/v1/foo/1/bar"
    end

    it "behaves by default for methods with bang" do
      expect { client.foo! }.to raise_error NoMethodError
    end
  end

  describe "#respond_to_missing?" do
    it "returns true for methods without bang" do
      expect(client).to respond_to :arbitrary_name
    end

    it "returns false for methods with bang" do
      expect(client).not_to respond_to :arbitrary_name!
    end
  end
end
