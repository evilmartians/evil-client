RSpec.describe Evil::Client::DSL::Files do
  subject do
    described_class.new(&block).call file:     "Hi!",
                                     charset:  "utf-16",
                                     type:     "application/json",
                                     filename: "greetings.json",
                                     text:     "Hoorah!"
  end

  context "from block without definitions:" do
    let(:block) { proc {} }

    it "provides an empty schema" do
      expect(subject).to eq([])
    end
  end

  context "from block with definitions:" do
    let(:block) do
      proc do |file:, **opts|
        add file, **opts
      end
    end

    it "provides a schema" do
      expect(subject).to be_a Array
      expect(subject.count).to eq 1

      item = subject.first
      expect(item[:file]).to be_a StringIO
      expect(item[:file].read).to eq "Hi!"
      expect(item[:type]).to eq MIME::Types["application/json"].first
      expect(item[:charset]).to eq "utf-16"
      expect(item[:filename]).to eq "greetings.json"
    end
  end
end
