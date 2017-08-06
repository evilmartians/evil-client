RSpec.describe Evil::Client::Container do
  let(:container) { described_class.new schema, logger, opts }
  let(:logger)    { Logger.new log }
  let(:log)       { StringIO.new }
  let(:opts) do
    { token: "qux", id: 7, language: "en_US", name: "Joe", age: 9 }
  end

  let(:settings_klass) do
    Class.new(Evil::Client::Settings) do
      option :token
      option :id
      option :language
      option :name
    end
  end

  let(:schema) do
    double :schema,
           to_s: "MyApi.users",
           parent: nil,
           settings: settings_klass,
           definitions: {}
  end

  describe ".new" do
    subject { container }

    it "logs given options" do
      subject
      expect(log.string).to include opts.to_s
    end

    it "logs initialized settings" do
      subject
      expect(log.string).to include container.settings.to_s
    end
  end

  describe "#to_s" do
    subject { container.to_s }

    it "returns human-friendly representation of container" do
      expect(subject).to eq \
        "#<MyApi.users @token=qux, @id=7, @language=en_US, @name=Joe>"
    end
  end

  describe "#to_str" do
    subject { container.to_str }

    it "returns human-friendly representation of container" do
      expect(subject).to eq \
        "#<MyApi.users @token=qux, @id=7, @language=en_US, @name=Joe>"
    end
  end

  describe "#inspect" do
    subject { container.inspect }

    it "returns human-friendly representation of container" do
      expect(subject).to eq \
        "#<MyApi.users @token=qux, @id=7, @language=en_US, @name=Joe>"
    end
  end

  describe "#logger" do
    subject { container.logger }

    it "returns current logger" do
      expect(subject).to eq logger
    end
  end

  describe "#logger=" do
    let(:new_logger) { Logger.new log }
    subject { container.logger = new_logger }

    it "sets new logger" do
      expect { subject }.to change { container.logger }.to new_logger
    end
  end

  describe "#schema" do
    subject { container.schema }

    it "returns current schema" do
      expect(subject).to eq schema
    end
  end

  describe "#settings" do
    subject { container.settings }

    it "returns current settings" do
      expect(subject).to be_a settings_klass
    end
  end

  describe "#options" do
    subject { container.options }

    it "returns settings options" do
      expect(subject).to eq token: "qux", id: 7, language: "en_US", name: "Joe"
    end
  end
end
