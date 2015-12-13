describe Evil::Client::Request do
  subject do
    described_class
      .new("https://www.example.com/foo")
      .with_type(:post)
      .with_path([:bar, 1, :baz])
      .with_query(foo: [:bar, :baz], baz: { qux: :QUX })
      .with_body(foo: [:bar, :baz], baz: { qux: :QUX })
      .with_headers("Foo" => "FOO", "Bar" => "BAR")
  end

  describe "#include?" do
    let(:other) do
      described_class
        .new("https://www.example.com/foo")
        .with_path(["bar/1/baz"])
        .with_type("POST")
    end

    context "request with the same type and path" do
      it { is_expected.to be_include other }
    end

    context "request with different type" do
      let(:another) { other.with_type(:patch) }

      it { is_expected.not_to include another }
    end

    context "request with different path" do
      let(:another) { other.with_path([:extra]) }

      it { is_expected.not_to include another }
    end

    context "request with subbody" do
      let(:another) { other.with_body "baz" => { "qux" => :QUX } }

      it { is_expected.to include another }
    end

    context "request with extra body" do
      let(:another) { other.with_body baz: :QUX }

      it { is_expected.not_to include another }
    end

    context "request with subquery" do
      let(:another) { other.with_query "baz" => { "qux" => :QUX } }

      it { is_expected.to include another }
    end

    context "request with extra query" do
      let(:another) { other.with_query baz: :QUX }

      it { is_expected.not_to include another }
    end

    context "request with subheaders" do
      let(:another) { other.with_headers :"Foo" => "FOO" }

      it { is_expected.to include another }
    end

    context "request with extra headers" do
      let(:another) { other.with_headers "Baz" => "BAZ" }

      it { is_expected.not_to include another }
    end
  end
end
