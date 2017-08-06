RSpec.describe Evil::Client::Resolver::Format, ".call" do
  subject { described_class.call schema, settings }

  let(:log)      { StringIO.new }
  let(:logger)   { Logger.new log }
  let(:settings) { double :my_settings, version: 77, logger: logger }

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { format: proc { :form } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { format: proc { version > 2 ? :json : :form } },
           parent: root_schema
  end

  it "resolves format from a schema" do
    expect(subject).to eq :json
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "json"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines a format" do
    before { schema.definitions.delete :format }

    it "resolves format from a parent schema" do
      expect(subject).to eq :form
    end
  end

  context "when format not defined by any schema" do
    before { schema.definitions.delete :format }
    before { root_schema.definitions.delete :format }

    it "resolves format to :json" do
      expect(subject).to eq :json
    end
  end

  context "when format resolves to inacceptable value" do
    before { schema.definitions[:format] = proc { :foo } }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }.to raise_error Evil::Client::DefinitionError,
                                        /foo/
    end
  end
end
