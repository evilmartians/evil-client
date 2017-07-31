RSpec.describe Evil::Client::Resolver::Body, ".call" do
  subject { described_class.call schema, settings }

  let(:log)      { StringIO.new }
  let(:logger)   { Logger.new log }
  let(:settings) { double :my_settings, version: 77, logger: logger }

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { body: proc { %W[v#{version}] } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { body: proc { { version: "v#{version}" } } },
           parent: root_schema
  end

  it "resolves body from a schema" do
    expect(subject).to eq version: "v77"
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "v77"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines a body" do
    before { schema.definitions.delete :body }

    it "resolves body from a parent schema" do
      expect(subject).to eq %w[v77]
    end
  end

  context "when root body definitions was reloaded by nil" do
    before { schema.definitions[:body] = proc {} }

    it "resolves body to nil" do
      expect(subject).to be_nil
    end
  end

  context "when body not defined by any schema" do
    before { schema.definitions.delete :body }
    before { root_schema.definitions.delete :body }

    it "resolves body to nil" do
      expect(subject).to be_nil
    end
  end
end
