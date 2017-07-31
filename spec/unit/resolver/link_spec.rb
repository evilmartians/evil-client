RSpec.describe Evil::Client::Resolver::Link, ".call" do
  subject { described_class.call schema, settings }

  let(:log)    { StringIO.new }
  let(:logger) { Logger.new log }

  let(:settings) do
    double :my_settings, version: 77, name: "users", logger: logger
  end

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { link: proc { "v#{version}" } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { link: proc { "path/#{name}" } },
           parent: root_schema
  end

  it "resolves link from a schema" do
    expect(subject).to eq "path/users"
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "path/users"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines a link" do
    before { schema.definitions.delete :link }

    it "resolves link from a parent schema" do
      expect(subject).to eq "v77"
    end
  end

  context "when parent schemas cannot be resolved" do
    let(:settings) { double :settings, name: "users", logger: logger }

    it "still resolves link from the latest schema" do
      expect(subject).to eq "path/users"
    end
  end

  context "when current schema cannot be resolved" do
    let(:settings) { double :my_settings, version: 1, logger: logger }

    it "raises StandardError" do
      expect { subject }.to raise_error StandardError
    end

    it "logs the result" do
      subject rescue nil

      expect(log.string).to include described_class.name
      expect(log.string).to include "my_schema"
      expect(log.string).to include "my_settings"
    end
  end
end
