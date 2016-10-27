RSpec.describe Evil::Client::Middleware::StringifyForm do
  let(:stack) { described_class.new(app) }
  let(:app)   { double :app }

  def update!(env)
    @result = env
  end

  before  { allow(app).to receive(:call) { |env| update! env } }
  subject { stack.call env }

  context "with a non-empty body:" do
    let(:env) do
      {
        body:   { foo: :FOO, bar: [:BAR], baz: { qux: :QUX }, qux: nil },
        format: "form"
      }
    end

    it "stringifies the body" do
      subject
      expect(@result[:body_string]).to eq "foo=FOO&bar[]=BAR&baz[qux]=QUX&qux="
    end

    it "adds content-type header" do
      subject
      expect(@result[:headers])
        .to eq "content-type" => "application/x-www-form-urlencoded"
    end
  end

  context "when format is not a form:" do
    let(:env) do
      {
        body:   { foo: :FOO, bar: [:BAR], baz: { qux: :QUX }, qux: nil },
        format: "json"
      }
    end

    it "does nothing" do
      subject
      expect(@result).to eq env
    end
  end

  context "with empty body:" do
    let(:env) { { body: {}, format: "form" } }

    it "does nothing" do
      subject
      expect(@result).to eq env
    end
  end

  context "without a body:" do
    let(:env) { { format: "form" } }

    it "does nothing" do
      subject
      expect(@result).to eq env
    end
  end
end
