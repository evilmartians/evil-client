RSpec.describe Evil::Client::Resolver::Query, ".call" do
  subject { described_class.call schema, settings }

  let(:log)    { StringIO.new }
  let(:logger) { Logger.new log }

  let(:settings) do
    double :my_settings, name: "Andy", gender: "man", logger: logger
  end

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { query: proc { { user: { name: name } } } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { query: proc { { user: { gender: gender } } } },
           parent: root_schema
  end

  it "resolves query from a schema" do
    expect(subject).to eq "user" => { "name" => "Andy", "gender" => "man" }
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "Andy"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines a query" do
    before { schema.definitions.delete :query }

    it "resolves query from a parent schema" do
      expect(subject).to eq "user" => { name: "Andy" }
    end
  end

  context "when current schema definitions incompatible to root" do
    before { schema.definitions[:query] = proc { { user: [gender: :man] } } }

    it "resolves query from a current schema only" do
      expect(subject).to eq "user" => [{ gender: :man }]
    end
  end

  context "when root query definitions was reloaded by nil" do
    before { schema.definitions[:query] = proc {} }

    it "resolves query to empty hash" do
      expect(subject).to eq({})
    end
  end

  context "when query not defined by any schema" do
    before { schema.definitions.delete :query }
    before { root_schema.definitions.delete :query }

    it "resolves query to empty hash" do
      expect(subject).to eq({})
    end
  end

  context "when query definition returns neither hash nor nil" do
    before { schema.definitions[:query] = proc { 1323 } }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }.to raise_error Evil::Client::DefinitionError,
                                        /1323/
    end
  end
end
