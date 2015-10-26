describe Evil::Client::Request do

  let(:klass) { Class.new(described_class) }
  before      { klass.id_provider = double(:provider, value: "default_id") }

  let(:request) { klass.new type, uri, data }
  let(:type)    { :get }
  let(:uri)     { "http://localhost/users/1/sms" }
  let(:data)    { { foo: :bar } }

  describe ".id_provider=" do
    subject { klass.id_provider = provider }

    let(:provider) { double :provider, value: "new_default_id" }

    it "sets provider for default id" do
      expect { subject }
        .to change { klass.default_id }
        .from("default_id")
        .to("new_default_id")
    end
  end

  describe ".new" do
    subject { request }

    context "with custom id" do
      before { klass.id_provider = nil }
      before { data.update(request_id: "custom_id") }

      it { is_expected.to be_kind_of described_class }
    end

    context "without id" do
      before { klass.id_provider = nil }

      it "fails" do
        expect { subject }.to raise_error Evil::Client::Errors::RequestIDError
      end
    end

    context "without uri" do
      let(:uri) { nil }

      it "fails" do
        expect { subject }.to raise_error Evil::Client::Errors::PathError
      end
    end
  end

  describe "#type" do
    subject { request.type }

    it { is_expected.to eql "get" }
  end

  describe "#uri" do
    subject { request.uri }
  
    it { is_expected.to eql uri }
  end

  describe "#params" do
    subject { request.params }

    context "for get request" do
      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "default_id" },
          query: { foo: :bar }
      end
    end

    context "for post request" do
      let(:type) { "post" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "default_id" },
          body: { foo: :bar }
      end
    end

    context "for patch request" do
      let(:type) { "patch" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "default_id" },
          body: { foo: :bar, _method: "patch" }
      end
    end

    context "for delete request" do
      let(:type) { "delete" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "default_id" },
          body: { foo: :bar, _method: "delete" }
      end
    end

    context "when request_id is set explicitly" do
      before { data.update request_id: "custom_id" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "custom_id" },
          query: { foo: :bar }
      end
    end
  end

  describe "#to_a" do
    subject { request.to_a }

    it "returns array to be sent to connection" do
      expect(subject).to eql [
        "get",
        "http://localhost/users/1/sms",
        { header: { "X-Request-Id" => "default_id" }, query: { foo: :bar } }
      ]
    end
  end
end
