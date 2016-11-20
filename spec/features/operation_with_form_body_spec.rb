RSpec.describe "operation with form body" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::User < Evil::Struct
      attribute :name
    end

    class Test::Client < Evil::Client
      operation do
        http_method :get
        path { "users" }
        response :success, 200
      end
    end

    stub_request(:get, //)
  end

  let(:path) { "https://foo.example.com/api/v3/users" }
  let(:client) { Test::Client.new "foo", user: "bar", version: 3, token: "baz" }
  let(:operation) { client.operations[:example] }

  context "without operation-specific definition" do
    before do
      class Test::Client < Evil::Client
        operation do
          http_method :get
          path { "users" }
          response :success, 200

          body format: "form" do
            attribute :foo
          end
        end

        operation :example do
        end
      end
    end

    it "uses the default one" do
      request = a_request(:get, path).with do |req|
        expect(req.body).to eq "foo[][bar][]=BAZ"
        expect(req.headers)
          .to include "Content-Type" => "application/x-www-form-urlencoded"
      end

      operation.call foo: [{ bar: [:BAZ] }], baz: :QUX

      expect(request).to have_been_made
    end
  end

  context "with operation-specific definition" do
    before do
      class Test::Client < Evil::Client
        operation do
          http_method :get
          path { "users" }
          response :success, 200

          body format: "form" do
            attribute :foo
          end
        end

        operation :example do
          body format: "form" do
            attribute :baz
          end
        end
      end
    end

    it "uses the specific one" do
      request = a_request(:get, path).with body: "baz=QUX"

      operation.call foo: [{ bar: [:BAZ] }], baz: :QUX

      expect(request).to have_been_made
    end
  end

  context "when appended with files" do
    before do
      class Test::Client < Evil::Client
        operation :example do
          body format: "form" do
            attribute :baz
          end

          files do
          end
        end
      end
    end

    it "skips body definition" do
      request = a_request(:get, path).with do |req|
        expect(req.body).to be_nil
      end

      operation.call foo: [{ bar: [:BAZ] }], baz: :QUX

      expect(request).to have_been_made
    end
  end

  context "with a model" do
    before do
      class Test::Client < Evil::Client
        operation :example do
          body format: "form", model: Test::User do
            attribute :foo
          end
        end
      end
    end

    it "extends the model" do
      request = a_request(:get, path).with body: "name=Andy&foo=BAR"

      operation.call foo: :BAR, name: "Andy"

      expect(request).to have_been_made
    end
  end

  context "with a model" do
    before do
      class Test::Client < Evil::Client
        operation :example do
          body format: "form" do
            attribute :foo, type: Dry::Types["strict.string"]
            attribute :bar, default: proc { 1 }
            attribute :baz, optional: true
          end
        end
      end
    end

    it "requires mandatory arguments" do
      expect { operation.call bar: 2, baz: 3 }.to raise_error(KeyError)
    end

    it "applies type restrictions" do
      expect { operation.call foo: :FOO }.to raise_error(TypeError)
    end

    it "uses default values and skips undefined optional attributes" do
      request = a_request(:get, path).with body: "foo=BAR&bar=1"

      operation.call foo: "BAR"

      expect(request).to have_been_made
    end
  end
end
