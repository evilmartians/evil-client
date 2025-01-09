RSpec.describe Evil::Client::Resolver::Middleware, ".call" do
  subject { described_class.call schema, settings }

  before do
    class Test::Foo; end
    class Test::Bar; end
    class Test::Baz; end
  end

  let(:log)    { StringIO.new }
  let(:logger) { Logger.new log }

  let(:settings) do
    double :my_settings, name: "Andy", gender: "man", logger: logger
  end

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { middleware: proc { [Test::Foo, Test::Bar] } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { middleware: proc { Test::Baz } },
           parent: root_schema
  end

  it "resolves middleware from a schema in a reverse order" do
    expect(subject).to eq [Test::Baz, Test::Bar, Test::Foo]
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "[Test::Baz, Test::Bar, Test::Foo]"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines a middleware" do
    before { schema.definitions.delete :middleware }

    it "resolves middleware from a parent schema in a reverse order" do
      expect(subject).to eq [Test::Bar, Test::Foo]
    end
  end

  context "when root middleware definitions was reloaded by nil" do
    before { schema.definitions[:middleware] = proc {} }

    it "resolves middleware to empty list" do
      expect(subject).to eq []
    end
  end

  context "when middleware not defined by any schema" do
    before { schema.definitions.delete :middleware }
    before { root_schema.definitions.delete :middleware }

    it "resolves middleware to empty list" do
      expect(subject).to eq []
    end
  end

  context "when middleware definition has wrong format" do
    before { schema.definitions[:middleware] = proc { 1323 } }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }.to raise_error Evil::Client::DefinitionError,
                                        /1323/
    end
  end
end
