describe Evil::Client::APIs do

  let(:apis) { described_class.new api }
  let(:api)  { double :api }

  before do
    allow(api).to receive(:url) { |v| "127.0.0.1/#{v}" if v == "users/1/sms" }
    allow(Evil::Client::API).to receive(:new) { api }
  end

  describe ".with" do
    subject { described_class.with options }

    let(:options) { { base_url: "127.0.0.1" } }

    it "builds and wraps api with options given" do
      expect(Evil::Client::API).to receive(:new).with(options)
      expect(subject).to be_kind_of described_class
      expect(subject.to_a).to eql [api]
    end
  end

  describe "#each" do
    context "with a block" do
      subject { apis.to_a }

      it "iterates by api" do
        expect(subject).to eql [api]
      end
    end

    context "without a block" do
      subject { apis.each }

      it "returns enumerator" do
        expect(subject).to be_kind_of Enumerator
        expect(subject.to_a).to eql [api]
      end
    end
  end

  describe "#api" do
    subject { apis.api address }

    let(:address) { "users/1/sms" }

    it "returns api that has given address" do
      expect(subject).to eql(api)
    end

    context "when api doesn't resolve url" do
      let(:address) { "users/1" }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, %r{'users/1'}
      end
    end

    context "when no api specified" do
      let(:apis) { described_class.new }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, %r{'users/1/sms'}
      end
    end
  end
end
