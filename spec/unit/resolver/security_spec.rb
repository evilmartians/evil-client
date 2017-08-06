RSpec.describe Evil::Client::Resolver::Security do
  let(:resolver) { described_class.new schema, settings }
  let(:log)      { StringIO.new }
  let(:logger)   { Logger.new log }

  let(:root_schema) do
    double :my_parent_schema,
           definitions: { security: proc { key_auth :token, token } },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           definitions: { security: proc { key_auth :user, user } },
           parent: root_schema
  end

  let(:settings) do
    double :my_settings,
           token: "foobar",
           user: "foo",
           password: "baz",
           logger: logger
  end

  describe ".call" do
    subject { described_class.call schema, settings }

    it "resolves security settings from a schema" do
      expect(subject).to eq headers: { "user" => "foo" }
    end

    it "logs the result" do
      subject

      expect(log.string).to include described_class.name
      expect(log.string).to include "my_schema"
      expect(log.string).to include "my_settings"
      expect(log.string).to include "foo"
    end

    context "when logger level was set to INFO" do
      before { logger.level = Logger::INFO }

      it "skips logging" do
        expect { subject }.not_to change { log.string }
      end
    end

    context "when current schema not defines security settings" do
      before { schema.definitions.delete :security }

      it "resolves security settings from a parent schema" do
        expect(subject).to eq headers: { "token" => "foobar" }
      end
    end

    context "when security settings not defined by any schema" do
      before { schema.definitions.delete :security }
      before { root_schema.definitions.delete :security }

      it "resolves security settings to nil" do
        expect(subject).to eq({})
      end
    end

    context "when security settings reloaded by nil" do
      before { schema.definitions[:security] = proc {} }

      it "resolves security settings to nil" do
        expect(subject).to eq({})
      end
    end

    context "when security settings resolves to unknown key" do
      before { schema.definitions[:security] = proc { { body: { id: 1 } } } }

      it "raises Evil::Client::DefinitionError" do
        expect { subject }.to raise_error Evil::Client::DefinitionError,
                                          /body/
      end
    end

    context "when security settings resolves to not a hash" do
      before { schema.definitions[:security] = proc { { query: :bar } } }

      it "raises Evil::Client::DefinitionError" do
        expect { subject }.to raise_error Evil::Client::DefinitionError,
                                          /bar/
      end
    end
  end

  describe "#key_auth" do
    let(:key)   { "foo" }
    let(:value) { "bar" }
    let(:opts)  { {} }

    subject { resolver.key_auth key, value, **opts }

    it "builds in-headers schema" do
      expect(subject).to eq headers: { "foo" => "bar" }
    end

    context "when :inside was set to :query" do
      let(:opts) { { inside: :query } }

      it "builds in-query schema" do
        expect(subject).to eq query: { "foo" => "bar" }
      end
    end
  end

  describe "#token_auth" do
    let(:value) { "foobar" }
    let(:opts)  { {} }

    subject { resolver.token_auth value, **opts }

    it "builds default in-headers schema for Authorization" do
      expect(subject).to eq headers: { "Authorization" => "foobar" }
    end

    context "when :prefix was set" do
      let(:opts) { { prefix: "bearer" } }

      it "builds prefixed in-headers schema" do
        expect(subject).to eq headers: { "Authorization" => "Bearer foobar" }
      end
    end

    context "when :inside was set to :query" do
      let(:opts) { { inside: :query } }

      it "builds default in-query schema for access_token" do
        expect(subject).to eq query: { "access_token" => "foobar" }
      end

      context "when :prefix was set" do
        let(:opts) { { inside: :query, prefix: "bearer" } }

        it "ignores prefix in a query" do
          expect(subject).to eq query: { "access_token" => "foobar" }
        end
      end
    end
  end

  describe "#basic_auth" do
    subject { resolver.basic_auth "foo", "bar" }

    it "builds basic Authorization schema" do
      expect(subject).to eq headers: { "Authorization" => "Basic Zm9vOmJhcg==" }
    end
  end
end
