RSpec.describe Evil::Client::Connection, ".call" do
  let(:logger) { Logger.new log }
  let(:log)    { StringIO.new }
  let(:env) do
    {
      "REQUEST_METHOD"  => "POST",
      "SCRIPT_NAME"     => "",
      "PATH_INFO"       => "/api/v77/users/43",
      "QUERY_STRING"    => "version=77&verbose=true",
      "SERVER_NAME"     => "foo.com",
      "SERVER_PORT"     => 443,
      "HTTP_Variables"  => {
        "Foo" => "BAR",
        "Baz" => "QUX",
        "Authorization" => "Bearer eoiqopr==",
        "Content-Type"  => "application/json"
      },
      "rack.version"      => Rack::VERSION,
      "rack.input"        => "name=Andrew&age=46",
      "rack.url_scheme"   => "https",
      "rack.multithread"  => false,
      "rack.multiprocess" => false,
      "rack.run_once"     => false,
      "rack.hijack?"      => false,
      "rack.logger"       => logger
    }
  end

  let(:request) do
    a_request(:post, "https://foo.com/api/v77/users/43?version=77&verbose=true")
      .with body: "name=Andrew&age=46",
            headers: {
              "Foo" => "BAR",
              "Baz" => "QUX",
              "Authorization" => "Bearer eoiqopr==",
              "Content-Type"  => "application/json"
            }
  end

  before do
    stub_request(:any, //).to_return status:  200,
                                     headers: { "Content-Language" => "en_AU" },
                                     body:    "Done!"
  end

  subject { described_class.call(env) }

  it "sends a request" do
    subject
    expect(request).to have_been_made
  end

  it "returns a response" do
    expect(subject).to eq [200, { "content-language" => ["en_AU"] }, ["Done!"]]
  end

  it "logs the request" do
    subject

    <<-LOG.gsub(/^ +\|/, "").lines.each { |l| expect(log.string).to include l }
      |INFO -- Evil::Client::Connection: sending request:
      |INFO -- Evil::Client::Connection:  Url     | https://foo.com/api/v77/users/43?version=77&verbose=true
      |INFO -- Evil::Client::Connection:  Headers | {"Foo"=>"BAR", "Baz"=>"QUX", "Authorization"=>"Bearer eoiqopr==", "Content-Type"=>"application/json"}
      |INFO -- Evil::Client::Connection:  Body    | name=Andrew&age=46
    LOG
  end

  it "logs the response" do
    subject

    <<-LOG.gsub(/^ +\|/, "").lines.each { |l| expect(log.string).to include l }
      |INFO -- Evil::Client::Connection: receiving response:
      |INFO -- Evil::Client::Connection:  Status  | 200
      |INFO -- Evil::Client::Connection:  Headers | {\"content-language\"=>[\"en_AU\"]}
      |INFO -- Evil::Client::Connection:  Body    | [\"Done!\"]
    LOG
  end
end
