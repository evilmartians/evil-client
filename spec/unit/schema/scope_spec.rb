RSpec.describe Evil::Client::Schema::Scope do
  let(:client) { class_double Evil::Client, name: "MyApi" }
  let(:parent) { described_class.new client }
  let(:schema) { described_class.new parent, :users }
  let(:block)  { proc { def self.foo; :FOO; end } }
  let(:dsl_methods) do
    %i[operations scopes options schema settings inspect logger]
  end

  it "subclasses the operation schema" do
    expect(described_class.superclass).to eq Evil::Client::Schema::Operation
  end

  describe "#leaf?" do
    subject { schema.leaf? }

    it "returns false" do
      expect(subject).to eq false
    end
  end

  describe "#scopes" do
    subject { schema.scopes }

    it "returns empty hash by default" do
      expect(subject).to eq({})
    end
  end

  describe "#scope" do
    subject { schema.scope(:customers, &block) }

    it "adds named subscope to the scope" do
      subject
      expect(schema.scopes[:customers]).to be_a described_class
    end

    it "executes the block in context of the new subscope" do
      subject
      expect(schema.scopes[:customers].foo).to eq :FOO
    end

    it "returns the scope itself" do
      expect(subject).to eq schema
    end

    context "when name is reserved by DSL" do
      it "raises Evil::Client::NameError" do
        dsl_methods.each do |name|
          expect { schema.scope(name, &block) }
            .to raise_error Evil::Client::NameError
        end
      end
    end

    context "when there is an operation with the same name" do
      before { schema.operation(:customers) {} }

      it "raises Evil::Client::TypeError" do
        expect { subject }.to raise_error Evil::Client::TypeError
      end
    end
  end

  describe "#operations" do
    subject { schema.operations }

    it "returns empty hash by default" do
      expect(subject).to eq({})
    end
  end

  describe "#operation" do
    subject { schema.operation(:fetch, &block) }

    it "adds named operation to the scope" do
      subject
      expect(schema.operations[:fetch]).to be_a Evil::Client::Schema::Operation
    end

    it "executes the block in context of the new operation" do
      subject
      expect(schema.operations[:fetch].foo).to eq :FOO
    end

    it "returns the scope itself" do
      expect(subject).to eq schema
    end

    context "when name is reserved by DSL" do
      it "raises Evil::Client::NameError" do
        dsl_methods.each do |name|
          expect { schema.operation(name, &block) }
            .to raise_error Evil::Client::NameError
        end
      end
    end

    context "when there is an operation with the same name" do
      before { schema.scope(:fetch) {} }

      it "raises Evil::Client::TypeError" do
        expect { subject }.to raise_error Evil::Client::TypeError
      end
    end
  end

  describe "#operation" do
  end
end
