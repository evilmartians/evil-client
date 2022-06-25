RSpec.describe Evil::Client::Container::Scope do
  let(:scope)  { described_class.new schema, nil, **opts }
  let(:opts) { { token: "qux", id: 7, language: "en_US", name: "Joe", age: 9 } }
  let(:update_schema) { double :update_schema, name: :update }
  let(:admins_schema) { double :admins_schema, name: :admins }

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
           parent: nil,
           settings: settings_klass,
           operations: { update: update_schema },
           scopes: { admins: admins_schema }
  end

  it "is a subclass of base container" do
    expect(described_class.superclass).to eq Evil::Client::Container
  end

  describe "#operations" do
    subject { scope.operations[:update] }

    it "contains sub-schemas with current settings" do
      expect(subject).to be_a Evil::Client::Builder::Operation
      expect(subject.schema).to eq update_schema
      expect(subject.parent).to eq scope.settings
    end
  end

  describe "#scopes" do
    subject { scope.scopes[:admins] }

    it "contains sub-schemas with current settings" do
      expect(subject).to be_a Evil::Client::Builder::Scope
      expect(subject.schema).to eq admins_schema
      expect(subject.parent).to eq scope.settings
    end
  end

  describe "chaining" do
    before do
      allow(scope.scopes[:admins])
        .to receive(:call) { |id:, **| "admins #{id}" }
      allow(scope.operations[:update])
        .to receive(:call) { |id:, **| "update #{id}" }
    end

    it "is supported" do
      expect(scope.admins(id: 8)).to eq "admins 8"
      expect(scope.update(id: 9)).to eq "update 9"
    end
  end
end
