RSpec.describe Evil::Client::Middleware::StringifyQuery do
  let(:stack) { described_class.new(app) }
  let(:app)   { double :app }

  def update!(env)
    @result = env
  end

  before  { allow(app).to receive(:call) { |env| update! env } }
  subject { stack.call env }

  context "with a non-empty query:" do
    let(:env) do
      { query: { foo: :FOO, bar: [:BAR], baz: { qux: :QUX }, qux: nil } }
    end

    it "stringifies the query" do
      subject
      expect(@result[:query_string]).to eq "foo=FOO&bar[]=BAR&baz[qux]=QUX&qux="
    end
  end

  context "with empty query:" do
    let(:env) { { query: {} } }

    it "does nothing" do
      subject
      expect(@result).to eq env
    end
  end

  context "without a query:" do
    let(:env) { {} }

    it "does nothing" do
      subject
      expect(@result).to eq env
    end
  end
end
