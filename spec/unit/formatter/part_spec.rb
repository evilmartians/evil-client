RSpec.describe Evil::Client::Formatter::Part do
  subject { described_class.call(value, 23).encode("utf-8") }

  context "when value is a file" do
    let(:value) do
      Tempfile.new(%w[hello .xml], encoding: "ascii-8bit").tap do |f|
        f.write "Hi!"
        f.rewind
      end
    end

    it "converts the value to a part of multipart body" do
      [
        "Content-Disposition: form-data; name=\"hello",
        "Content-Type: application/xml; charset=ascii-8bit",
        "Hi!"
      ].each { |str| expect(subject).to include str }
    end

    after do
      value.close
      value.unlink
    end
  end

  context "when value is a StringIO" do
    let(:value) { StringIO.new "Упс!".force_encoding "windows-1251" }

    it "converts the value to a part of multipart body" do
      [
        "Content-Disposition: form-data; name=\"Part23\"",
        "Content-Type: text/plain; charset=windows-1251",
        "РЈРїСЃ!"
      ].each { |str| expect(subject).to include str }
    end
  end

  context "when value is a string" do
    let(:value) { "Hi!" }

    it "converts the value to a part of multipart body" do
      [
        "Content-Disposition: form-data; name=\"Part23\"",
        "Content-Type: text/plain; charset=utf-8",
        "Hi!"
      ].each { |str| expect(subject).to include str }
    end
  end
end
