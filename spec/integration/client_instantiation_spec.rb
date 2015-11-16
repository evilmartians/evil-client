describe "client instantiation" do

  it "hides default constructor" do
    expect(Evil::Client).not_to respond_to :new
  end

  let(:client) { Evil::Client.with base_url: base_url }

  context "with valid http url" do
    let(:base_url) { "http://github.com/evilmartians" }

    it "builds the client" do
      expect(client).to be_kind_of Evil::Client
    end
  end

  context "with valid https url" do
    let(:base_url) { "https://127.0.0.1" }

    it "builds the client" do
      expect(client).to be_kind_of Evil::Client
    end
  end

  context "with base_url not containing a protocol" do
    let(:base_url) { "github.com/evilmartians" }

    it "raises URLError" do
      expect { client }.to raise_error \
        Evil::Client::Errors::URLError, %r{'github.com/evilmartians'}
    end
  end

  context "with base_url not containing a host" do
    let(:base_url) { "http://" }

    it "raises URLError" do
      expect { client }.to raise_error \
        Evil::Client::Errors::URLError, %r{'http://'}
    end
  end

  context "without base_url" do
    let(:client) { Evil::Client.with }

    it "fails" do
      expect { client }.to raise_error ArgumentError
    end
  end
end
