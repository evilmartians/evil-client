RSpec.describe Evil::Client::DSL::Operation do
  let(:operation) { described_class.new(:some_operation, block) }
  let(:settings)  { double version: 3, user: "foo", password: "bar" }

  subject { operation.finalize(settings) }

  context "without definitions" do
    let(:block) { proc {} }
    it "returns a hash" do
      expect(subject).to eq key: :some_operation, responses: {}
    end
  end

  context "with #documentation" do
    let(:block) do
      proc { |settings| documentation "https://foo.bar/v#{settings.version}" }
    end

    it "defines link to :doc" do
      expect(subject[:doc]).to eq "https://foo.bar/v3"
    end
  end

  context "with #http_method" do
    let(:block) do
      proc { |settings| http_method settings.version > 2 ? "post" : "get" }
    end

    it "defines :method" do
      expect(subject[:method]).to eq "post"
    end
  end

  context "with #path" do
    let(:block) do
      proc do |settings|
        path { |id:, **| "/v#{settings.version}/users/#{id}/" }
      end
    end

    it "defines :path without trailing slashes" do
      path = subject[:path]
      expect(path).to be_kind_of Proc
      expect(path.call(id: 55)).to eq "v3/users/55"
    end
  end

  context "with #files" do
    let(:block) do
      proc do
        files do |file:, **options|
          add file, **options
        end
      end
    end

    it "sets format to file" do
      expect(subject[:format]).to eq "multipart"
    end

    it "defines schema for a file" do
      file = Tempfile.new

      schema = subject[:files].call file:     file,
                                    type:     "text/html",
                                    charset:  "utf-16"

      expect(schema).to contain_exactly \
        file:     file,
        type:     MIME::Types["text/html"].first,
        charset:  "utf-16",
        filename: nil
    end

    it "wraps string to StringIO" do
      schema = subject[:files].call file: "Hello!"
      file = schema.first[:file]

      expect(file).to be_kind_of StringIO
      expect(file.read).to eq "Hello!"
    end
  end

  context "with #security" do
    let(:block) do
      proc do |settings|
        security do
          basic_auth settings.user, settings.password
        end
      end
    end

    it "defines :security schema" do
      expect(subject[:security].call)
        .to eq headers: { "authorization" => "Basic Zm9vOmJhcg==" }
    end
  end

  context "with #body" do
    context "with block without :model" do
      let(:block) do
        proc do |_|
          body do
            attribute :foo
            attribute :bar
          end
        end
      end

      it "sets format to json" do
        expect(subject[:format]).to eq "json"
      end

      it "defines :block as model filter" do
        model = subject[:body][foo: :FOO, bar: :BAR, baz: :BAZ]
        expect(model).to eq foo: :FOO, bar: :BAR
      end
    end

    context "with :model without block" do
      before do
        class Test::Foo < Evil::Client::Model
          attribute :qux
        end
      end

      let(:block) do
        proc do |_|
          body type: Test::Foo
        end
      end

      it "defines :block as model filter" do
        model = subject[:body][foo: :FOO, bar: :BAR, qux: :QUX, baz: :BAZ]
        expect(model).to eq qux: :QUX
      end
    end

    context "with :model and block" do
      before do
        class Test::Foo < Evil::Client::Model
          attribute :qux
        end
      end

      let(:block) do
        proc do |_|
          body type: Test::Foo do
            attribute :foo
            attribute :bar
          end
        end
      end

      it "defines :block as model filter" do
        model = subject[:body][foo: :FOO, bar: :BAR, qux: :QUX, baz: :BAZ]
        expect(model).to eq foo: :FOO, bar: :BAR, qux: :QUX
      end
    end
  end

  context "with #query" do
    before do
      class Test::Foo < Evil::Client::Model
        attribute :qux
      end
    end

    let(:block) do
      proc do |settings|
        query type: Test::Foo do
          attribute settings.user
          attribute :bar
        end
      end
    end

    it "defines :block as model filter" do
      model = subject[:query][foo: :FOO, bar: :BAR, qux: :QUX, baz: :BAZ]
      expect(model).to eq foo: :FOO, bar: :BAR, qux: :QUX
    end
  end

  context "with #headers" do
    before do
      class Test::Foo < Evil::Client::Model
        attribute :qux
      end
    end

    let(:block) do
      proc do |settings|
        headers type: Test::Foo do
          attribute settings.user
          attribute :bar
        end
      end
    end

    it "defines :block as model filter" do
      model = subject[:headers][foo: :FOO, bar: :BAR, qux: :QUX, baz: :BAZ]
      expect(model).to eq foo: :FOO, bar: :BAR, qux: :QUX
    end
  end

  context "with #response" do
    let(:response_schema)  { subject[:responses][200] }
    let(:response_raise)   { response_schema[:raise] }
    let(:response_coercer) { response_schema[:coercer] }

    context "with plain format" do
      let(:body)  { "foo" }
      let(:block) { proc { |_| response 200, format: :plain } }

      it "works" do
        expect(response_coercer.call(body)).to eq "foo"
      end
    end

    context "with plain format and handler" do
      let(:body) { "foo" }
      let(:block) do
        proc do |_|
          response 200, format: :plain do |body|
            body.to_sym
          end
        end
      end

      it "applies coercer" do
        expect(response_coercer.call(body)).to eq :foo
      end
    end

    context "with plain format and type" do
      let(:body) { "0" }
      let(:block) do
        proc do |_|
          response 200, format: :plain, type: Dry::Types["coercible.int"]
        end
      end

      it "uses type" do
        expect(response_coercer.call(body)).to eq 0
      end
    end

    context "with plain format, coercer and type" do
      let(:body) { "0" }
      let(:block) do
        proc do |_|
          response 200, format: :plain, type: Dry::Types["coercible.string"] do |value|
            value.to_i + 1
          end
        end
      end

      it "applies coercer and then type" do
        expect(response_coercer.call(body)).to eq "1"
      end
    end

    context "with json format" do
      let(:body) { '{"foo":1,"baz":"qux"}' }
      let(:block) { proc { |_| response 200, format: :json } }

      it "returns parsed body" do
        expect(response_coercer.call(body)).to eq "foo" => 1, "baz" => "qux"
      end
    end

    context "with json format and handler" do
      let(:body) { '{"foo":1,"baz":"qux"}' }
      let(:block) do
        proc do |_|
          response 200, format: :json do |body|
            body.keys
          end
        end
      end

      it "returns parsed and handled body" do
        expect(response_coercer.call(body)).to eq %w(foo baz)
      end
    end

    context "with json format and type" do
      before do
        class Test::Foo < Evil::Client::Model
          attribute :foo
        end
      end

      let(:body) { '{"foo":1,"baz":"qux"}' }
      let(:block) do
        proc do |_|
          response 200, format: :json, type: Test::Foo
        end
      end

      it "returns parsed and filtered body" do
        expect(response_coercer.call(body)).to eq foo: 1
      end
    end

    context "with json format, type and handler" do
      before do
        class Test::Foo < Evil::Client::Model
          attribute :foo
        end
      end

      let(:body) { '{"foo":1,"baz":"qux"}' }
      let(:block) do
        proc do |_|
          response 200, format: :json, type: Test::Foo do |body|
            body["foo"] = body["foo"].to_s
            body
          end
        end
      end

      it "returns parsed, handled and filtered body" do
        expect(response_coercer.call(body)).to eq Test::Foo.new(foo: "1")
      end
    end

    context "with json format and filter" do
      before do
        class Test::Foo < Evil::Client::Model
          attribute :foo
        end
      end

      let(:body) { '{"foo":1,"baz":"qux"}' }
      let(:block) do
        proc do |_|
          response 200, format: :json do
            attribute :baz
          end
        end
      end

      it "returns parsed and filtered body" do
        expect(response_coercer.call(body)).to eq baz: "qux"
      end
    end

    context "with json format, type and filter" do
      before do
        class Test::Foo < Evil::Client::Model
          attribute :foo
        end
      end

      let(:body) { '{"foo":1,"baz":2}' }
      let(:block) do
        proc do |_|
          response 200, format: :json, type: Test::Foo do
            attribute :baz, Dry::Types["coercible.string"]
          end
        end
      end

      it "returns parsed and filtered body" do
        expect(response_coercer.call(body)).to eq foo: 1, baz: "2"
      end
    end
  end
end
