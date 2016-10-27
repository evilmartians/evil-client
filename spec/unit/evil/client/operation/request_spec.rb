RSpec.describe Evil::Client::Operation::Request do
  before do
    class Test::Body < Evil::Client::Model
      attribute :foo
    end

    class Test::Query < Evil::Client::Model
      attribute :bar
    end

    class Test::Headers < Evil::Client::Model
      attribute :baz
    end
  end

  let(:request) { described_class.new(schema) }
  let(:file)    { StringIO.new "Hi!" }
  let(:schema) do
    {
      format:   "multipart",
      method:   "patch",
      path:     proc { |id:, **| "users/#{id}" },
      files:    Evil::Client::DSL::Files.new { |file:, **| add file },
      security: Evil::Client::DSL::Security.new { basic_auth "qux", "abc" },
      query:    Test::Query,
      body:     Test::Body,
      headers:  Test::Headers
    }
  end

  subject { request.build file: file, foo: :FOO, bar: :BAR, baz: :BAZ, id: 1 }

  it "builds final request env" do
    expect(subject).to eq \
      format:      "multipart",
      http_method: "patch",
      path:        "users/1",
      security: { headers: { "authorization" => "Basic cXV4OmFiYw==" } },
      files:    [{
        file:     file,
        type:     MIME::Types["text/plain"].first,
        charset:  "utf-8",
        filename: nil
      }],
      query:   { bar: :BAR },
      body:    { foo: :FOO },
      headers: { baz: :BAZ }
  end
end
