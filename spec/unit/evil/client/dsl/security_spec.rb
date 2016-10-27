RSpec.describe Evil::Client::DSL::Security do
  subject { described_class.new(&block).call }

  context "from block without definitions:" do
    let(:block) { proc {} }

    it "provides an empty schema" do
      expect(subject).to eq({})
    end
  end

  context "from block with #key_auth using headers:" do
    let(:block) do
      proc do
        key_auth "foo", "bar"
      end
    end

    it "provides a schema" do
      expect(subject).to eq headers: { "foo" => "bar" }
    end
  end

  context "from block with #key_auth using body:" do
    let(:block) do
      proc do
        key_auth "foo", "bar", using: :body
      end
    end

    it "provides a schema" do
      expect(subject).to eq body: { "foo" => "bar" }
    end
  end

  context "from block with #key_auth using query:" do
    let(:block) do
      proc do
        key_auth "foo", "bar", using: :query
      end
    end

    it "provides a schema" do
      expect(subject).to eq query: { "foo" => "bar" }
    end
  end

  context "from block with #key_auth using unknown part:" do
    let(:block) do
      proc do
        key_auth "foo", "bar", using: :unknown
      end
    end

    it "fails" do
      expect { subject }.to raise_error ArgumentError
    end
  end

  context "from block with #token_auth using headers:" do
    let(:block) do
      proc do
        token_auth "foo"
      end
    end

    it "provides a schema" do
      expect(subject).to eq headers: { "authorization" => "foo" }
    end
  end

  context "from block with #token_auth with a prefix:" do
    let(:block) do
      proc do
        token_auth "foo", prefix: "Digest"
      end
    end

    it "provides a schema" do
      expect(subject).to eq headers: { "authorization" => "Digest foo" }
    end
  end

  context "from block with #token_auth using body:" do
    let(:block) do
      proc do
        token_auth "foo", using: :body
      end
    end

    it "provides a schema" do
      expect(subject).to eq body: { "access_token" => "foo" }
    end
  end

  context "from block with #token_auth using query:" do
    let(:block) do
      proc do
        token_auth "foo", using: :query
      end
    end

    it "provides a schema" do
      expect(subject).to eq query: { "access_token" => "foo" }
    end
  end

  context "from block with #basic_auth:" do
    let(:block) do
      proc do
        basic_auth "foo", "bar"
      end
    end

    it "provides a schema" do
      expect(subject)
        .to eq headers: { "authorization" => "Basic Zm9vOmJhcg==" }
    end
  end

  context "from block with several definitions:" do
    let(:block) do
      proc do
        basic_auth "foo", "bar"
        token_auth "baz", using: :query
      end
    end

    it "provides a full schema" do
      expect(subject).to eq \
        headers: { "authorization" => "Basic Zm9vOmJhcg==" },
        query:   { "access_token" => "baz" }
    end
  end
end
