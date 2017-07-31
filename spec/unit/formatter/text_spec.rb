RSpec.describe Evil::Client::Formatter::Text do
  subject { described_class.call(source) }

  context "from file" do
    let(:source) do
      Tempfile.new(%w[hello .xml], encoding: "ascii-8bit").tap do |f|
        f.write "Hi!"
        f.rewind
      end
    end

    it "reads the file" do
      expect(subject).to eq "Hi!"
    end

    after do
      source.close
      source.unlink
    end
  end

  context "from a StringIO" do
    let(:source) { StringIO.new "Hello!" }

    it "reads the IO" do
      expect(subject).to eq "Hello!"
    end
  end

  context "from another source" do
    let(:source) { %i[2384] }

    it "stringifies the source" do
      expect(subject).to eq '[:"2384"]'
    end
  end
end
