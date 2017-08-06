RSpec.describe Evil::Client::Resolver::Response, ".call" do
  subject { described_class.call schema, settings, response }

  let(:log)      { StringIO.new }
  let(:logger)   { Logger.new log }
  let(:response) { [201, { "Content-Language" => "en" }, ["success"]] }

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { responses: { 201 => proc { |*args| args } } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: {
             responses: { 201 => proc { |_, _, body| body.first } }
           },
           parent: root_schema
  end

  let(:settings) do
    double :my_settings, version: 77, token: "eoiqopr==", id: 43, logger: logger
  end

  it "applies most recent schema to response" do
    expect(subject).to eq "success"
  end

  it "logs the result" do
    subject

    expect(log.string).to include described_class.name
    expect(log.string).to include "my_schema"
    expect(log.string).to include "my_settings"
    expect(log.string).to include "201"
    expect(log.string).to include "success"
  end

  context "when logger level was set to INFO" do
    before { logger.level = Logger::INFO }

    it "skips logging" do
      expect { subject }.not_to change { log.string }
    end
  end

  context "when root definition not reloaded" do
    before { schema.definitions[:responses].delete 201 }

    it "applies root schema to response" do
      expect(subject).to eq response
    end
  end

  context "when no definitions was given for the status" do
    let(:response) { [202, { "Content-Language" => "en" }, ["success"]] }

    it "raises Evil::Client::ResponseError" do
      expect { subject }.to raise_error Evil::Client::ResponseError,
                                        /202/
    end
  end
end
