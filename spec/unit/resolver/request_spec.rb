RSpec.describe Evil::Client::Resolver::Request, ".call" do
  subject { described_class.call schema, settings }

  let(:log)    { StringIO.new }
  let(:logger) { Logger.new log }

  let(:root_schema) do
    double :my_parent_schema,
           definitions: {
             body: proc { %W[v#{version}] },
             format: proc { :form },
             headers: proc { { "Foo" => "BAR" } },
             http_method: proc { :get },
             query: proc { { version: version } },
             security: proc { token_auth token },
             path: proc { "https://myhost.com/api/v#{version}" }
           },
           parent: nil
  end

  let(:schema) do
    double :my_schema,
           to_s: "MySchema.users.fetch",
           definitions: {
             body: proc { { version: "v#{version}" } },
             format: proc { :json if version > 76 },
             headers: proc { { "Baz" => "QUX" } },
             http_method: proc { :post if version > 75 },
             query: proc { { verbose: true } },
             security: proc { token_auth token, prefix: "Bearer" },
             path: proc { "users/#{id}" }
           },
           parent: root_schema
  end

  let(:opts)     { { version: 77, token: "eoiqopr==", id: 43 } }
  let(:settings) { double :my_settings, options: opts, logger: logger, **opts }

  let(:environment) do
    {
      "REQUEST_METHOD" => "POST",
      "SCRIPT_NAME" => "",
      "PATH_INFO" => "/api/v77/users/43",
      "QUERY_STRING" => "version=77&verbose=true",
      "SERVER_NAME" => "myhost.com",
      "SERVER_PORT" => 443,
      "HTTP_Variables" => {
        "Foo" => "BAR",
        "Baz" => "QUX",
        "Authorization" => "Bearer eoiqopr==",
        "Content-Type" => "application/json"
      },
      "rack.version" => Rack::VERSION,
      "rack.input" => '{"version":"v77"}',
      "rack.url_scheme" => "https",
      "rack.multithread" => false,
      "rack.multiprocess" => false,
      "rack.run_once" => false,
      "rack.hijack?" => false,
      "rack.logger" => logger
    }
  end

  context "with default :json format" do
    it "resolves request schema for settings to rack-compatible env" do
      expect(subject).to eq environment
    end
  end

  context "with :yaml format" do
    before do
      schema.definitions[:format] = -> { :yaml }
      environment["rack.input"] = "---\n:version: v77\n"
      environment["HTTP_Variables"]["Content-Type"] = "application/yaml"
    end

    it "resolves request schema for settings to rack-compatible env" do
      expect(subject).to eq environment
    end
  end

  context "with :text format" do
    before do
      schema.definitions[:format] = -> { :text }
      environment["rack.input"] = '{:version=>"v77"}'
      environment["HTTP_Variables"]["Content-Type"] = "text/plain"
    end

    it "resolves request schema for settings to rack-compatible env" do
      expect(subject).to eq environment
    end
  end

  context "with :form format" do
    before do
      schema.definitions[:format] = -> { :form }
      environment["rack.input"] = "version=v77"
      environment["HTTP_Variables"]["Content-Type"] = \
        "application/x-www-form-urlencoded"
    end

    it "resolves request schema for settings to rack-compatible env" do
      expect(subject).to eq environment
    end
  end

  context "with :multipart format" do
    before { schema.definitions[:format] = -> { :multipart } }

    it "resolves request schema for settings to rack-compatible env" do
      expect(subject["HTTP_Variables"]["Content-Type"])
        .to match %r{multipart/form-data; boundary=\w{20}}

      expect(subject["rack.input"])
        .to include 'Content-Disposition: form-data; name="Part1"'

      expect(subject["rack.input"])
        .to include "version=v77"
    end
  end
end
