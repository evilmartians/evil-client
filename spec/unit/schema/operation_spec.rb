RSpec.describe Evil::Client::Schema::Operation do
  let(:client) { class_double Evil::Client, name: "MyApi" }
  let(:parent) { described_class.new client }
  let(:schema) { described_class.new parent, :users }
  let(:block)  { -> { "bar" } }

  it "subclasses the base schema" do
    expect(described_class.superclass).to eq Evil::Client::Schema
  end

  describe "#leaf?" do
    subject { schema.leaf? }

    it "returns true" do
      expect(subject).to eq true
    end
  end

  describe "definitions" do
    subject { schema.definitions }

    it "is a hash with empty responses" do
      expect(subject).to eq responses: {}
    end
  end

  describe "#path" do
    context "with block syntax" do
      subject { schema.path(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:path] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.path "foo" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:path]&.call }
          .to "foo"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#link" do
    context "with block syntax" do
      subject { schema.link(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:link] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.link "foo" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:link]&.call }
          .to "foo"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#http_method" do
    context "with block syntax" do
      subject { schema.http_method(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:http_method] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.http_method "foo" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:http_method]&.call }
          .to "foo"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#format" do
    context "with block syntax" do
      subject { schema.format(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:format] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.format "foo" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:format]&.call }
          .to "foo"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#security" do
    context "with block syntax" do
      subject { schema.security(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:security] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.security "foo" => "bar" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:security]&.call }
          .to "foo" => "bar"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#headers" do
    context "with block syntax" do
      subject { schema.headers(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:headers] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.headers "foo" => "bar" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:headers]&.call }
          .to "foo" => "bar"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#query" do
    context "with block syntax" do
      subject { schema.query(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:query] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.query "foo" => "bar" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:query]&.call }
          .to "foo" => "bar"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#body" do
    context "with block syntax" do
      subject { schema.body(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:body] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      subject { schema.body "foo" => "bar" }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:body]&.call }
          .to "foo" => "bar"
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#middleware" do
    context "with block syntax" do
      subject { schema.middleware(&block) }

      it "adds block to definitions" do
        expect { subject }
          .to change { schema.definitions[:middleware] }
          .to block
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "with plain syntax" do
      before  { class Test::Foo; end }
      subject { schema.middleware Test::Foo }

      it "wraps value to block and adds it to definitions" do
        expect { subject }
          .to change { schema.definitions[:middleware]&.call }
          .to Test::Foo
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#response" do
    context "with a block" do
      subject { schema.response(200, 201, &block) }

      it "adds block to responses under given keys" do
        expect { subject }
          .to change { schema.definitions[:responses] }
          .to(200 => block, 201 => block)
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end

    context "without a block" do
      subject { schema.response(200) }

      it "adds identity block to responses under given keys" do
        subject

        expect(schema.definitions.dig(:responses, 200).call("Hi")).to eq %w[Hi]
      end

      it "returns the schema itself" do
        expect(subject).to eq schema
      end
    end
  end

  describe "#responses" do
    context "with a block" do
      subject { schema.responses(200, 201, &block) }

      it "is an alias for #response" do
        expect { subject }
          .to change { schema.definitions[:responses] }
          .to(200 => block, 201 => block)
      end
    end
  end
end
