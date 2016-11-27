RSpec.describe Evil::Client::Middleware::StringifyJson do
  def update!(result)
    @result = result
  end

  let(:app) { double :app }

  before  { allow(app).to receive(:call) { |env, *| update!(env) } }
  subject { described_class.new(app).call(env, {}, {}) }

  context "with a body:" do
    let(:env) { { format: "json", body: { foo: :bar } } }

    it "stringifies a body" do
      subject
      expect(@result[:body_string]).to eq '{"foo":"bar"}'
    end

    it "sets content-type" do
      subject
      expect(@result[:headers]).to eq "content-type" => "application/json"
    end
  end

  context "when format is not json:" do
    let(:env) { { format: "form", body: { foo: :bar } } }

    it "does nothing" do
      subject
      expect(@result).to eq env
    end
  end

  context "with empty body:" do
    let(:env) { { format: "json", body: {} } }

    it "stringifies an empty body" do
      subject
      expect(@result[:body_string]).to eq "{}"
    end

    it "sets content-type" do
      subject
      expect(@result[:headers]).to eq "content-type" => "application/json"
    end
  end

  context "without a body:" do
    let(:env) { { format: "json" } }

    it "stringifies an empty body" do
      subject
      expect(@result[:body_string]).to eq "{}"
    end

    it "sets content-type" do
      subject
      expect(@result[:headers]).to eq "content-type" => "application/json"
    end
  end
end
