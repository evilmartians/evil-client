describe "client instantiation" do

  let(:client) { Evil::Client.new base_url }

  context "with valid http url" do
    let(:base_url) { "http://github.com/evilmartians:8080" }

    it "builds the client" do
      expect(client).to be_kind_of Evil::Client
    end
  end

  context "with valid https url" do
    let(:base_url) { "https://127.0.0.1/foobar:445" }

    it "builds the client" do
      expect(client).to be_kind_of Evil::Client
    end
  end

  context "with base_url not containing a protocol" do
    let(:base_url) { "github.com/evilmartians" }

    it "uses http" do
      expect(client.uri).to eql "http://github.com/evilmartians"
    end
  end

  context "with base_url not containing a host" do
    let(:base_url) { "http://" }

    it "fails" do
      expect { client }.to raise_error(StandardError)
    end
  end
end
