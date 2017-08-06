RSpec.describe Evil::Client::Resolver::Uri, ".call" do
  subject { described_class.call schema, settings }

  let(:log)      { StringIO.new }
  let(:logger)   { Logger.new log }
  let(:settings) { double :my_settings, version: 77, id: 42, logger: logger }

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { path: proc { "https://my_api.com/v#{version}" } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { path: proc { "/users/#{id}" } },
           parent: root_schema
  end

  it "resolves uri from a schema" do
    expect(subject).to eq URI("https://my_api.com/v77/users/42")
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "https://my_api.com/v77/users/42"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when current schema not defines an uri" do
    before { schema.definitions.delete :path }

    it "resolves uri from a parent schema" do
      expect(subject).to eq URI("https://my_api.com/v77")
    end
  end

  context "when path was defined with errors" do
    before { root_schema.definitions.delete :path }

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

  context "when uri cannot be resolved" do
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

  context "when path wasn't defined" do
    before { root_schema.definitions.delete :path }
    before { schema.definitions.delete :path }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }
        .to raise_error Evil::Client::DefinitionError,
                        /base url should be defined/
    end

    it "logs the result" do
      subject rescue nil

      expect(log.string).to include described_class.name
      expect(log.string).to include "my_schema"
      expect(log.string).to include "my_settings"
    end
  end

  context "when uri has a wrong schema" do
    before { root_schema.definitions[:path] = proc { "ws://github.com" } }

    it "raises Evil::Client::DefinitionError" do
      expect { subject }
        .to raise_error Evil::Client::DefinitionError,
                        /base url should use HTTP\(S\). 'ws' used instead/
    end

    it "logs the result" do
      subject rescue nil

      expect(log.string).to include described_class.name
      expect(log.string).to include "my_schema"
      expect(log.string).to include "my_settings"
    end
  end
end
