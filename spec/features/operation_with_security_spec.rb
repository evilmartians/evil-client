RSpec.describe "operation with security" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::Client < Evil::Client
      operation do
        http_method :get
        path { "data" }
        response :success, 200
      end
    end

    stub_request(:get, //)
  end

  let(:path) { "https://foo.example.com/api/v3/data" }
  let(:client) do
    Test::Client.new "foo",
                     version:  3,
                     user:     "bar",
                     password: "baz",
                     token:    "qux"
  end

  subject { client.operations[:example].call }

  context "without operation-specific settings" do
    before do
      class Test::Client < Evil::Client
        operation do |settings|
          http_method :get
          path { "data" }
          response :success, 200

          security do
            basic_auth settings.user, settings.password
          end
        end

        operation :example
      end
    end

    it "uses default settings" do
      request = a_request(:get, path).with do |req|
        expect(req.headers).to include "Authorization" => "Basic YmFyOmJheg=="
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with basic_auth" do
    before do
      class Test::Client < Evil::Client
        operation :example do |settings|
          security { basic_auth settings.user, settings.password }
        end
      end
    end

    it "adds header" do
      request = a_request(:get, path).with do |req|
        expect(req.headers).to include "Authorization" => "Basic YmFyOmJheg=="
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with prefixed token_auth in headers" do
    before do
      class Test::Client < Evil::Client
        operation :example do |settings|
          security { token_auth settings.token, prefix: "Bearer" }
        end
      end
    end

    it "adds header" do
      request = a_request(:get, path).with do |req|
        expect(req.headers).to include "Authorization" => "Bearer qux"
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with token_auth without prefix in headers" do
    before do
      class Test::Client < Evil::Client
        operation :example do |settings|
          security { token_auth settings.token }
        end
      end
    end

    it "adds header" do
      request = a_request(:get, path).with do |req|
        expect(req.headers).to include "Authorization" => "qux"
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with token_auth in query" do
    before do
      class Test::Client < Evil::Client
        operation :example do |settings|
          security { token_auth settings.token, using: :query }
        end
      end
    end

    it "adds options to query" do
      request = a_request(:get, "#{path}?access_token=qux").with do |req|
        expect(req.headers.keys).not_to include "Authorization"
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with token_auth in json body" do
    before do
      class Test::Client < Evil::Client
        operation :example do |settings|
          security { token_auth settings.token, using: :body }
          body format: "json"
        end
      end
    end

    it "adds options to body" do
      request = a_request(:get, path).with do |req|
        expect(req.body).to eq '{"access_token":"qux"}'
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with token_auth in a plain(form) body" do
    before do
      class Test::Client < Evil::Client
        operation :example do |settings|
          security { token_auth settings.token, using: :body }
          body format: "form"
        end
      end
    end

    it "adds options to body" do
      request = a_request(:get, path).with do |req|
        expect(req.body).to eq "access_token=qux"
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with key_auth in headers" do
    before do
      class Test::Client < Evil::Client
        operation :example do
          security { key_auth "fOo", "bAr" }
        end
      end
    end

    it "adds header" do
      request = a_request(:get, path).with do |req|
        expect(req.headers).to include "Foo" => "bAr"
      end

      subject
      expect(request).to have_been_made
    end
  end

  context "with key_auth in query" do
    before do
      class Test::Client < Evil::Client
        operation :example do |_settings|
          security { key_auth :fOo, :bAr, using: :query }
        end
      end
    end

    it "adds options to query" do
      request = a_request(:get, "#{path}?fOo=bAr")

      subject
      expect(request).to have_been_made
    end
  end

  context "with several methods at once" do
    before do
      class Test::Client < Evil::Client
        operation :example do |_settings|
          security do
            key_auth   "foo", "bar", using: :query
            key_auth   "baz", "qux"
            basic_auth "foo", "bar"
          end
        end
      end
    end

    it "combines definitions" do
      request = a_request(:get, "#{path}?foo=bar").with do |req|
        expect(req.headers).to include "Authorization" => "Basic Zm9vOmJhcg==",
                                       "Baz" => "qux"
      end

      subject
      expect(request).to have_been_made
    end
  end
end
