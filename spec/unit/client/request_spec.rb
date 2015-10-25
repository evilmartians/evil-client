describe Evil::Client::Request do

  let(:request) { described_class.new api, type, path, data }
  let(:api)     { double(:api, adapter: double, request_id: "bazqux") }
  let(:type)    { :get }
  let(:path)    { "foo/bar" }
  let(:data)    { { foo: :bar } }

  before { allow(api).to receive(:uri) { |path| "localhost/#{path}" } }

  describe ".new" do
    subject { request }
  
    it "instantiates request" do
      expect(subject.api).to  eql api
      expect(subject.type).to eql "get"
      expect(subject.path).to eql path
      expect(subject.data).to eql data
    end
  end

  describe "#adapter" do
    subject { request.adapter }

    it { is_expected.to eql api.adapter }
  end

  describe "#uri" do
    subject { request.uri }
  
    it { is_expected.to eql "localhost/foo/bar" }
  end

  describe "#params" do
    subject { request.params }

    context "for get request" do
      let(:type) { "get" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "bazqux" },
          query: { foo: :bar }
      end
    end

    context "for post request" do
      let(:type) { "post" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "bazqux" },
          body: { foo: :bar }
      end
    end

    context "for patch request" do
      let(:type) { "patch" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "bazqux" },
          body: { foo: :bar, _method: "patch" }
      end
    end

    context "for delete request" do
      let(:type) { "delete" }

      it "returns proper parameters" do
        expect(subject).to eql \
          header: { "X-Request-Id" => "bazqux" },
          body: { foo: :bar, _method: "delete" }
      end
    end
  end

  describe "#validate" do
    subject { request.validate }

    it { is_expected.to eql request }

    context "when path is absent" do
      before { allow(api).to receive(:uri) { nil } }

      it "fails" do
        expect { subject }.to raise_error \
          Evil::Client::Errors::PathError, %r{'foo/bar'}
      end
    end
  end

  describe "#to_a" do
    subject { request.to_a }

    it "returns array to be sent to connection" do
      expect(subject).to eql [
        "get",
        "localhost/foo/bar",
        { header: { "X-Request-Id" => "bazqux" }, query: { foo: :bar } }
      ]
    end
  end
end
