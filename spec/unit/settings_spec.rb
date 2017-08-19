RSpec.describe Evil::Client::Settings do
  let(:settings) { klass.new(logger, options) }
  let(:log)      { StringIO.new }
  let(:logger)   { Logger.new log }
  let(:schema)   { double :schema, to_s: "Test::Api.users.update" }
  let(:klass)    { described_class.for(schema) }
  let(:options)  { { "id" => 42, "name" => "Andrew" } }
  let(:dsl_methods) do
    %i[options datetime logger scope basic_auth key_auth token_auth]
  end

  describe ".for" do
    subject { klass }

    it "subclasses itself" do
      expect(subject.superclass).to eq described_class
    end

    it "keeps the schema" do
      expect(subject.schema).to eq schema
    end
  end

  describe ".option" do
    it "is defined by Dry::Initializer DSL" do
      expect(klass).to be_a Dry::Initializer
    end

    it "fails when method name is reserved for DSL" do
      dsl_methods.each do |name|
        expect { klass.option name }
          .to raise_error Evil::Client::NameError
      end
    end

    it "allows the option to be renamed" do
      expect { klass.option :basic_auth, as: :something }.not_to raise_error
    end
  end

  describe ".param" do
    before do
      klass.param :id,    optional: true
      klass.param :email, optional: true
    end

    subject { settings.options }

    it "acts like .option" do
      expect(subject).to eq id: 42
    end
  end

  describe ".let" do
    before do
      klass.param :id
      klass.let(:square_id) { id**2 }
    end

    subject { settings.square_id }

    it "adds the corresponding memoizer to the instance" do
      expect(subject).to eq(42**2)
    end

    it "fails when method name is reserved for DSL" do
      dsl_methods.each do |name|
        expect { klass.let(name) { 0 } }
          .to raise_error Evil::Client::NameError
      end
    end
  end

  describe ".validate" do
    before do
      klass.param :name
      klass.validate(:name_present) { name.to_s != "" }
    end

    let(:options) { { "name" => "" } }

    it "adds validation for an instance" do
      # see spec/fixtures/locale/en.yml
      expect { settings }
        .to raise_error(Evil::Client::ValidationError, "The user has no name")
    end

    it "gives logger to validators" do
      settings rescue nil

      expect(log.string).to include "#{klass.schema}.validator[:name_present]"
      expect(log.string).to include "failed"
    end
  end

  describe ".name" do
    subject { klass.name }

    it "represents settins class in a human-friendly manner" do
      expect(subject).to eq "Test::Api.users.update"
    end
  end

  describe ".inspect" do
    subject { klass.inspect }

    it "represents settins class in a human-friendly manner" do
      expect(subject).to eq "Test::Api.users.update"
    end
  end

  describe ".to_s" do
    subject { klass.to_s }

    it "represents settins class in a human-friendly manner" do
      expect(subject).to eq "Test::Api.users.update"
    end
  end

  describe ".to_str" do
    subject { klass.to_str }

    it "represents settins class in a human-friendly manner" do
      expect(subject).to eq "Test::Api.users.update"
    end
  end

  describe ".new" do
    subject { settings }

    it "sets the logger" do
      expect(subject.logger).to eq logger
    end

    it "logs the initial params" do
      subject

      expect(log.string).to include klass.to_s
      expect(log.string).to include options.to_s
      expect(log.string).to include settings.to_s
      expect(log.string).to include "initialized"
    end

    context "when logger level was set to INFO" do
      before { logger.level = Logger::INFO }

      it "skips logging" do
        expect { subject }.not_to change { log.string }
      end
    end

    context "with wrong options" do
      before { klass.option :user, as: :customer }

      it "raises Evil::Client::ValidationError" do
        expect { subject }.to raise_error Evil::Client::ValidationError, /user/
      end
    end
  end

  describe "#logger=" do
    let(:new_logger) { double }
    subject { settings.logger = new_logger }

    it "sets a new logger" do
      expect { subject }.to change { settings.logger }.to new_logger
    end
  end

  describe "#options" do
    before do
      klass.option :id,    optional: true
      klass.option :email, optional: true
    end

    subject { settings.options }

    it "slices declared options from the assigned ones" do
      expect(subject).to eq id: 42
    end

    it "responds to #slice and #except" do
      expect(subject).to respond_to :slice
      expect(subject).to respond_to :except
    end
  end

  describe "#datetime" do
    let(:time) { DateTime.parse "2017-07-21 16:58:00 UTC" }
    subject { settings.datetime value }

    context "with a parceable string" do
      let(:value) { time.to_s }

      it "applies RFC2822" do
        expect(subject).to eq "Fri, 21 Jul 2017 16:58:00 +0000"
      end
    end

    context "with a date" do
      let(:value) { time.to_date }

      it "applies RFC2822" do
        expect(subject).to eq "Fri, 21 Jul 2017 00:00:00 +0000"
      end
    end

    context "with a time" do
      let(:value) { time }

      it "applies RFC2822" do
        expect(subject).to eq "Fri, 21 Jul 2017 16:58:00 +0000"
      end
    end

    context "with a datetime" do
      let(:value) { time.to_datetime }

      it "applies RFC2822" do
        expect(subject).to eq "Fri, 21 Jul 2017 16:58:00 +0000"
      end
    end

    context "with unparseable value" do
      let(:value) { "foo" }

      it "raises ArgumentError" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#to_s" do
    subject { settings.to_s }

    it "represents instance of settings in a human-friendly manner" do
      expect(subject).to include "#<Test::Api.users.update:"
    end
  end

  describe "#to_str" do
    subject { settings.to_str }

    it "represents instance of settings in a human-friendly manner" do
      expect(subject).to include "#<Test::Api.users.update:"
    end
  end

  describe "#inspect" do
    subject { settings.inspect }

    it "represents instance of settings in a human-friendly manner" do
      expect(subject).to include "#<Test::Api.users.update:"
    end
  end
end
