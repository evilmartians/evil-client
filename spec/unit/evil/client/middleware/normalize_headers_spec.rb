RSpec.describe Evil::Client::Middleware::NormalizeHeaders do
  let(:stack) { described_class.new(app) }
  let(:app)   { double :app }
  let(:env)   { { headers: { Foo: :BAR } } }

  def update!(env)
    @result = env
  end

  before  { allow(app).to receive(:call) { |env| update! env } }
  subject { stack.call env }

  it "normalizes headers" do
    subject
    expect(@result[:headers]).to eq "foo" => "BAR"
  end
end
