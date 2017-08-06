RSpec.describe Evil::Client::Builder::Scope do
  let(:builder) { described_class.new schema, parent }
  let(:options) { { id: 83, password: "qux", age: 38 } }
  let(:parent)  { double :parent, options: { user: "foo", password: "bar" } }
  let(:schema)  { double :schema, name: "fetch", settings: settings }

  let(:settings) do
    Class.new(Evil::Client::Settings) do
      option :id
      option :user
      option :password
    end
  end

  describe "#to_s" do
    subject { builder.to_s }

    it "represents the builder in a human-friendly manner" do
      expect(subject).to eq "#[Double :parent].scopes[:fetch]"
    end
  end

  describe "#to_str" do
    subject { builder.to_str }

    it "represents the builder in a human-friendly manner" do
      expect(subject).to eq "#[Double :parent].scopes[:fetch]"
    end
  end

  describe "#inspect" do
    subject { builder.inspect }

    it "represents the builder in a human-friendly manner" do
      expect(subject).to eq "#[Double :parent].scopes[:fetch]"
    end
  end

  describe "#schema" do
    subject { builder.schema }

    it "refers to the wrapped schema" do
      expect(subject).to eq schema
    end
  end

  describe "#parent" do
    subject { builder.parent }

    it "refers to wrapped parent" do
      expect(subject).to eq parent
    end
  end

  describe "#new" do
    subject { builder.new options }

    it "creates scope with inherited options accepted by settings" do
      expect(subject).to be_a Evil::Client::Container::Scope
      expect(subject.schema).to eq schema
      expect(subject.options).to eq id: 83, user: "foo", password: "qux"
    end
  end

  describe "#call" do
    subject { builder.call options }

    it "creates scope with inherited options accepted by settings" do
      expect(subject).to be_a Evil::Client::Container::Scope
      expect(subject.schema).to eq schema
      expect(subject.options).to eq id: 83, user: "foo", password: "qux"
    end
  end

  describe "#[]" do
    subject { builder[options] }

    it "creates scope with inherited options accepted by settings" do
      expect(subject).to be_a Evil::Client::Container::Scope
      expect(subject.schema).to eq schema
      expect(subject.options).to eq id: 83, user: "foo", password: "qux"
    end
  end
end
