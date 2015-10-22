describe Evil::Client::Registry do

  let(:registry) { described_class.new default: api }
  let(:api)  { double :api }

  before do
    allow(api).to receive(:url) { |v| "127.0.0.1/#{v}" if v == "users/1/sms" }
    allow(Evil::Client::API).to receive(:new) { api }
  end

  describe "#each" do
    context "with a block" do
      subject { registry.to_a }

      it "iterates by api" do
        expect(subject).to eql [api]
      end
    end

    context "without a block" do
      subject { registry.each }

      it "returns enumerator" do
        expect(subject).to be_kind_of Enumerator
        expect(subject.to_a).to eql [api]
      end
    end
  end

  describe "#filter" do
    subject { registry.filter :sms }

    let(:registry) { described_class.new default: api, sms: api, users: api }

    it "returns new collection" do
      expect(subject).to be_kind_of described_class
      expect(subject).not_to eql registry
    end

    it "filters registry by keys" do
      expect(subject.count).to eql 1
    end

    context "by several keys" do
      subject { registry.filter :sms, :users, :unknown }

      it "filters registry by keys" do
        expect(subject.count).to eql 2
      end
    end

    context "without arguments" do
      subject { registry.filter }

      it { is_expected.to eql registry }
    end
  end

  describe "#api" do
    subject { registry.api url: url }

    let(:url) { "users/1/sms" }

    it "returns api that has given url" do
      expect(subject).to eql(api)
    end

    context "when api doesn't resolve url" do
      let(:url) { "users/1" }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, %r{'users/1'}
      end
    end

    context "when specified registry list is empty" do
      subject { registry.api :unregistered, url: url }

      it "fails" do
        expect { subject }
          .to raise_error Evil::Client::Errors::URLError, %r{'users/1/sms'}
      end
    end
  end

  describe ".with" do
    subject { described_class.with options }

    let(:options) { { base_url: "127.0.0.1" } }

    it "builds and wraps api with options given" do
      expect(Evil::Client::API).to receive(:new).with(options)
      expect(subject).to be_kind_of described_class
      expect(subject.to_a).to eql [api]
    end

    it "gives :default name" do
      expect(subject.filter(:default)).to be_one
    end
  end
end
