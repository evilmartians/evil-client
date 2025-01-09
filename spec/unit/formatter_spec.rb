RSpec.describe Evil::Client::Formatter do
  subject { described_class.call source, format, boundary: "foobar" }

  let(:source) { { foo: :bar } }

  context "for :json format" do
    let(:format) { :json }

    it "returns formatted body as json" do
      expect(subject).to eq '{"foo":"bar"}'
    end
  end

  context "for :yaml format" do
    let(:format) { :yaml }

    it "returns formatted body as yaml" do
      expect(subject).to eq "---\n:foo: :bar\n"
    end
  end

  context "for :text format" do
    let(:format) { :text }

    it "returns formatted body as plain text" do
      if Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3.4.0")
        expect(subject).to eq "{:foo=>:bar}"
      else
        expect(subject).to eq "{foo: :bar}"
      end
    end
  end

  context "for :form format" do
    let(:format) { :form }

    it "returns formatted body as form/urlencoded" do
      expect(subject).to eq "foo=bar"
    end
  end

  context "for :multipart format" do
    let(:format) { :multipart }

    it "returns formatted body as a multipart" do
      expect(subject).to include "--foobar"
      expect(subject).to include "foo=bar"
    end
  end
end
