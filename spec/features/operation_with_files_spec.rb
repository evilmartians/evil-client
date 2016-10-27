RSpec.describe "operation with files" do
  # see Test::Client definition in `/spec/support/test_client.rb`
  before do
    class Test::Client < Evil::Client
      operation :example do
        http_method :get
        path { "users" }
        response 200

        files do |file:, **|
          add file, type: "text/xml", charset: "utf-16", filename: "foo.xml"
        end
      end
    end

    stub_request(:get, //)
  end

  let(:path) { "https://foo.example.com/api/v3/users" }
  let(:client) { Test::Client.new "foo", user: "bar", version: 3, token: "baz" }

  subject { client.operations[:example].call file: "Hi!" }

  it "builds a multipart body" do
    request = a_request(:get, path).with do |req|
      expect(req.body).to include "Content-Disposition: form-data;" \
                                  ' name="AttachedFile1"; filename="foo.xml"'

      expect(req.body).to include "Content-Type: text/xml; charset=utf-16"

      expect(req.body).to include "Hi!"

      expect(req.headers["Content-Type"]).to include "multipart/form-data"
    end

    subject

    expect(request).to have_been_made
  end
end
