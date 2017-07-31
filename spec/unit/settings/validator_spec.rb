RSpec.describe Evil::Client::Settings::Validator do
  let(:validator) { described_class.new(schema, key, &block) }
  let(:schema)    { double to_s: "Test::Api.users.update" }
  let(:key)       { :token_present }
  let(:block)     { proc { 1 if token.to_s != "" } }

  describe ".new" do
    subject { validator }
    it { is_expected.to be_a described_class }

    context "when key is missed" do
      let(:key) { nil }

      it "raises ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when key is empty" do
      let(:key) { "" }

      it "raises ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when key cannot be symbolized" do
      let(:key) { 1 }

      it "raises ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end

    context "when block is missed" do
      let(:block) { nil }

      it "raises ArgumentError" do
        expect { subject }.to raise_error ArgumentError
      end
    end
  end

  describe "#to_s" do
    subject { validator.to_s }

    it "represents validator in a human-friendly manner" do
      expect(subject).to eq "Test::Api.users.update.validator[:token_present]"
    end
  end

  describe "#to_str" do
    subject { validator.to_str }

    it "represents validator in a human-friendly manner" do
      expect(subject).to eq "Test::Api.users.update.validator[:token_present]"
    end
  end

  describe "#inspect" do
    subject { validator.inspect }

    it "represents validator in a human-friendly manner" do
      expect(subject).to eq "Test::Api.users.update.validator[:token_present]"
    end
  end

  describe "#call" do
    let(:log)      { StringIO.new }
    let(:logger)   { Logger.new(log) }
    let(:options)  { { id: 7, token: token } }
    let(:token)    { "foo" }

    let(:settings) do
      double options: options, to_s: "my_settings", logger: logger, **options
    end

    subject { validator.call settings }

    context "when block returns truthy value" do
      it { is_expected.to eql true }

      it "logs the result" do
        subject

        expect(log.string).to include validator.to_s
        expect(log.string).to include "passed for my_settings"
      end

      context "when logger level was set to INFO" do
        before { logger.level = Logger::INFO }

        it "skips logging" do
          expect { subject }.not_to change { log.string }
        end
      end
    end

    context "when block returns falsey value" do
      let(:token) { nil }

      it "raises Evil::Client::ValidationError" do
        # see spec/fixtures/locales/en.yml
        expect { subject }
          .to raise_error Evil::Client::ValidationError,
                          "To update user id:7 you must provide a token"
      end

      it "logs the result" do
        subject rescue nil

        expect(log.string).to include validator.to_s
        expect(log.string).to include "failed for my_settings"
      end
    end

    context "when block raises" do
      let(:block) { proc { raise "my_problem" } }

      it "logs the result" do
        subject rescue nil

        expect(log.string).to include validator.to_s
        expect(log.string).to include "broken for my_settings with my_problem"
      end
    end
  end
end
