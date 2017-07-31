RSpec.describe Evil::Client::Schema do
  let(:client) { class_double Evil::Client, name: "MyApi" }
  let(:parent) { described_class.new client }
  let(:schema) { described_class.new parent, :users }

  describe "#client" do
    context "for a root schema" do
      subject { parent.client }

      it "is taken from initializer" do
        expect(subject).to eq client
      end
    end

    context "for a subschema" do
      subject { schema.client }

      it "is taken from parent" do
        expect(subject).to eq client
      end
    end
  end

  describe "#parent" do
    context "for a root schema" do
      subject { parent.parent }

      it "is absent" do
        expect(subject).to be_nil
      end
    end

    context "for a subschema" do
      subject { schema.parent }

      it "is taken from the initializer" do
        expect(subject).to eq parent
      end
    end
  end

  describe "#name" do
    context "for a root schema" do
      subject { parent.name }

      it "is taken from client" do
        expect(subject).to eq client.name
      end
    end

    context "for a subschema" do
      subject { schema.name }

      it "is taken from the initializer" do
        expect(subject).to eq :users
      end
    end
  end

  describe "#to_s" do
    context "for a root schema" do
      subject { parent.to_s }

      it "returns the name" do
        expect(subject).to eq "MyApi"
      end
    end

    context "for a subschema" do
      subject { schema.to_s }

      it "returns full name" do
        expect(subject).to eq "MyApi.users"
      end
    end
  end

  describe "#to_str" do
    subject { schema.to_str }

    it "is an alias for #to_s" do
      expect(subject).to eq schema.to_s
    end
  end

  describe "#inspect" do
    subject { schema.inspect }

    it "is an alias for #to_s" do
      expect(subject).to eq schema.to_s
    end
  end

  describe "#settings" do
    context "for a root schema" do
      subject { parent.settings }

      it "is a subclass of Evil::Client::Settings" do
        expect(subject).to be_a Class
        expect(subject.superclass).to eq Evil::Client::Settings
      end
    end

    context "for a subschema" do
      subject { schema.settings }

      it "is a subclass of parent settings" do
        expect(subject).to be_a Class
        expect(subject.superclass).to eq parent.settings
      end
    end
  end

  describe "#option" do
    before  { allow(schema.settings).to receive(:let) }
    subject { schema.option(:user, optional: true) }

    it "is delegated to settings" do
      expect(schema.settings)
        .to receive(:option).with(:user, nil, optional: true)

      subject
    end

    it "returns the schema itself" do
      expect(subject).to eq schema
    end
  end

  describe "#let" do
    before  { allow(schema.settings).to receive(:let) }
    subject { schema.let(:user) {} }

    it "is delegated to settings" do
      expect(schema.settings).to receive(:let).with(:user)
      subject
    end

    it "returns the schema itself" do
      expect(subject).to eq schema
    end
  end

  describe "#validate" do
    before  { allow(schema.settings).to receive(:validate) }
    subject { schema.validate(:id_present) {} }

    it "is delegated to settings" do
      expect(schema.settings).to receive(:validate).with(:id_present)
      subject
    end

    it "returns the schema itself" do
      expect(subject).to eq schema
    end
  end
end
