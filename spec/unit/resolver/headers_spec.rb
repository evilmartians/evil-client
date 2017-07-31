RSpec.describe Evil::Client::Resolver::Headers, ".call" do
  subject { described_class.call schema, settings }

  let(:log)    { StringIO.new }
  let(:logger) { Logger.new log }

  let(:settings) do
    double :my_settings, name: "foo", value: "bar", logger: logger
  end

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { headers: proc { { name: name.capitalize } } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { headers: proc { { Value: value.upcase } } },
           parent: root_schema
  end

  it "resolves headers from a schema" do
    expect(subject).to eq "name" => "Foo", "Value" => "BAR"
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "Foo"
  end

  context "when some header has empty value" do
    before { schema.definitions[:headers] = proc { { Value: "" } } }

    it "is ignored" do
      expect(subject).to eq "name" => "Foo"
    end
  end

  context "when header values are arrays" do
    before { schema.definitions[:headers] = proc { { foo: [:bar] } } }

    it "resolves header values to array of strings" do
      expect(subject).to eq "foo" => ["bar"], "name" => "Foo"
    end
  end

  context "when header values are nested arrays" do
    before { schema.definitions[:headers] = proc { { foo: [[:bar]] } } }

    it "resolves header values to array of strings" do
      expect(subject).to eq "foo" => ["[:bar]"], "name" => "Foo"
    end
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines headers" do
    before { schema.definitions.delete :headers }

    it "resolves headers from a parent schema only" do
      expect(subject).to eq "name" => "Foo"
    end
  end

  context "when headers not defined by any schema" do
    before { schema.definitions.delete :headers }
    before { root_schema.definitions.delete :headers }

    it "resolves headers to empty hash" do
      expect(subject).to eq({})
    end
  end

  context "when headers resolves to inacceptable value" do
    before { schema.definitions[:headers] = proc { :foo } }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }.to raise_error Evil::Client::DefinitionError,
                                        /foo/
    end
  end
end
