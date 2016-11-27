RSpec.describe Evil::Client::Middleware::MergeSecurity do
  let(:stack) { described_class.new(app) }
  let(:app)   { double :app }

  def update!(env)
    @result = env
  end

  before  { allow(app).to receive(:call) { |env, *| update! env } }
  subject { stack.call env, {}, {} }

  let(:env) do
    {
      body:    { "foo" => :FOO, "access_key" => :FOO },
      query:   { "bar" => :BAR, "access_key" => :FOO },
      headers: { "baz" => :BAZ, "authorization" => :FOO },
      security: {
        body:    { "access_key" => :QUX },
        query:   { "access_key" => :ZYX },
        headers: { "authorization" => "Basic 3ou08314tq==" }
      }
    }
  end

  it "merges security schema to env" do
    subject
    expect(@result).to eq \
      body:    { "foo" => :FOO, "access_key" => :QUX },
      query:   { "bar" => :BAR, "access_key" => :ZYX },
      headers: { "baz" => :BAZ, "authorization" => "Basic 3ou08314tq==" }
  end
end
