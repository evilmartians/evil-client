RSpec.describe Evil::Client::Resolver::HttpMethod, ".call" do
  subject { described_class.call schema, settings }

  let(:log)      { StringIO.new }
  let(:logger)   { Logger.new log }
  let(:settings) { double :my_settings, version: 77, logger: logger }

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { http_method: proc { :put } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { http_method: proc { version > 2 ? :patch : :put } },
           parent: root_schema
  end

  it "resolves http method from a schema" do
    expect(subject).to eq "PATCH"
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "PATCH"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines a http method" do
    before { schema.definitions.delete :http_method }

    it "resolves http method from a parent schema" do
      expect(subject).to eq "PUT"
    end
  end

  context "when http method resolves to inacceptable value" do
    before { schema.definitions[:http_method] = proc { :foo } }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }.to raise_error Evil::Client::DefinitionError,
                                        /FOO/
    end
  end

  context "when http method not defined by any schema" do
    before { schema.definitions.delete :http_method }
    before { root_schema.definitions.delete :http_method }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }.to raise_error Evil::Client::DefinitionError,
                                        /http_method/
    end
  end
end
