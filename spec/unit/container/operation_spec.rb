RSpec.describe Evil::Client::Container::Operation do
  before do
    Test::Middleware = Struct.new(:app) do
      def call(env)
        env["HTTP_Variables"].update("Accept-Language" => "ru_RU")
        app.call env
      end
    end
  end

  let(:operation)  { described_class.new(schema, nil, **opts) }
  let(:connection) { Evil::Client::Connection }
  let(:schema) do
    double :schema,
           to_s: "MyApi.users.update",
           client: double(:client, connection: connection),
           parent: nil,
           settings: settings_klass,
           definitions: {
             path: -> { "https://example.com/users/#{id}" },
             http_method: -> { "PATCH" },
             format: -> { :json },
             security: -> { { headers: { "Authentication" => token } } },
             headers: -> { { "Content-Language" => language } },
             query: -> { { language: language } },
             body: -> { { name: name } },
             middleware: -> { Test::Middleware },
             responses: { 200 => proc { |_, _, body| JSON.parse body.first } }
           }
  end

  let(:settings_klass) do
    Class.new(Evil::Client::Settings) do
      option :token
      option :id
      option :language
      option :name
    end
  end

  let(:opts) { { token: "qux", id: 7, language: "en_US", name: "Joe", age: 9 } }

  before do
    stub_request(:any, //).to_return status: 200, body: '{"result":"success"}'
  end

  it "is a subclass of base container" do
    expect(described_class.superclass).to eq Evil::Client::Container
  end

  describe "#call" do
    subject { operation.call }

    let(:request) do
      a_request(:patch, "https://example.com/users/7?language=en_US") do |r|
        expect(r.body).to eq '{"name":"Joe"}'
        expect(r.headers).to include "Authentication" => "qux",
                                     "Content-Language" => "en_US",
                                     "Accept-Language" => "ru_RU"
      end
    end

    it "sends resolved request" do
      subject
      expect(request).to have_been_made
    end

    it "returns parsed response" do
      expect(subject).to eq "result" => "success"
    end

    context "when a client has custom connection" do
      let(:connection) { double call: [200, {}, %w[{"result":"wow"}]] }

      it "sends request to selected connection" do
        expect(connection).to receive(:call)
        expect(subject).to eq "result" => "wow"
      end
    end
  end
end
