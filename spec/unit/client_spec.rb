RSpec.describe Evil::Client do
  let(:klass) { Class.new(described_class) }

  describe ".schema" do
    subject { klass.schema }

    it "returns a schema for the root scope" do
      expect(subject).to be_a described_class::Schema::Scope
      expect(subject.client).to eq klass
    end
  end

  describe ".scopes" do
    before  { klass.schema.scope(:users) {} }
    subject { klass.scopes }

    it "returns subscopes from the root schema" do
      expect(subject).to eq(klass.schema.scopes(nil))
    end
  end

  describe ".operations" do
    before  { klass.schema.operation(:users) {} }
    subject { klass.operations }

    it "returns operationss from the root schema" do
      expect(subject).to eq klass.schema.operations
    end
  end

  describe ".option" do
    subject { klass.option(:users, optional: true) }

    it "updates settings of the root schema" do
      expect(klass.schema.settings)
        .to receive(:option)
        .with :users, nil, optional: true

      subject
    end
  end

  describe ".scope" do
    subject { klass.scope(:users) {} }

    it "updates root schema scopes" do
      expect(klass.schema).to receive(:scope).with(:users, any_args)

      subject
    end
  end

  describe ".operation" do
    subject { klass.operation(:users) {} }

    it "updates root schema scopes" do
      expect(klass.schema).to receive(:operation).with(:users, any_args)

      subject
    end
  end

  describe ".connection" do
    subject { klass.connection }

    it "return Evil::Client::Connection module by default" do
      expect(subject).to eq Evil::Client::Connection
    end
  end

  describe ".connection=" do
    let(:new_connection) { double call: nil }
    subject { klass.connection = new_connection }

    it "sets new connection" do
      expect { subject }.to change { klass.connection }.to new_connection
    end

    context "with nil" do
      before  { klass.connection = new_connection }
      subject { klass.connection = nil }

      it "resets connection to default" do
        expect { subject }
          .to change { klass.connection }
          .to Evil::Client::Connection
      end
    end
  end

  let(:client) do
    klass.option :token
    klass.new(token: "foo", version: 1)
  end

  describe "#settings" do
    subject { client.settings }

    it "returns settings assigned to client settings" do
      expect(subject.token).to eq "foo"
    end
  end

  describe "#options" do
    subject { client.options }

    it "returns options assigned to client settings" do
      expect(subject).to eq token: "foo"
    end
  end

  describe "#scopes" do
    subject { client.scopes }

    it "returns root scope scopes" do
      expect(subject).to eq client.scope.scopes
    end
  end

  describe "#operations" do
    subject { client.operations }

    it "returns root scope operations" do
      expect(subject).to eq client.scope.operations
    end
  end

  describe "#logger" do
    before  { client.scope.logger = double :logger }
    subject { client.logger }

    it "returns root scope logger" do
      expect(subject).to eq client.scope.logger
    end
  end

  describe "#logger=" do
    let(:new_logger) { double :logger }
    subject { client.logger = new_logger }

    it "sets root scope logger" do
      expect { subject }.to change { client.scope.logger }.to new_logger
    end
  end
end
