RSpec.describe Evil::Client::Middleware::StringifyMultipart::Part do
  let(:file)    { StringIO.new "Hello!" }
  let(:type)    { MIME::Types["text/html"].first }
  let(:charset) { "utf-8" }
  let(:part) do
    described_class.new(file: file, type: type, charset: charset)
  end

  subject { part.to_s }

  shared_examples :building_part do
    it "includes content disposition" do
      expect(subject).to include \
        'Content-Disposition: form-data; name="AttachedFile"; filename='
    end

    it "includes content type" do
      expect(subject).to include "Content-Type: text/html; charset=utf-8"
    end

    it "includes content" do
      expect(subject).to include "Hello!"
    end
  end

  context "with a name" do
    let(:part) { described_class.new(file: file, name: "UploadedFile") }

    it "includes part name" do
      expect(subject).to include 'name="UploadedFile"'
    end
  end

  context "with a filename" do
    let(:part) { described_class.new(file: file, filename: "weird_thing.json") }

    it "includes part name" do
      expect(subject).to include 'filename="weird_thing.json"'
    end
  end

  context "from file" do
    let(:file) { instance_double ::File, path: "foo/bar.html", read: "Hello!" }
    it_behaves_like :building_part

    it "includes filename" do
      expect(subject).to include 'filename="bar.html"'
    end
  end

  context "from io" do
    it_behaves_like :building_part
  end

  context "from text" do
    let(:file) { "Hello!" }
    it_behaves_like :building_part
  end
end
