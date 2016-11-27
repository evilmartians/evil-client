describe Evil::Client::DSL::Operations do
  let(:operations) { described_class.new }
  let(:settings) do
    double(:settings, version: 1, user: "foo", password: "bar")
  end

  before do
    operations.register(nil) do |settings|
      http_method :post
      security    { basic_auth settings.user, settings.password }
    end

    operations.register(:find_user) do |_|
      http_method :get
      path        { |id:, **| "/users/#{id}" }
    end
  end

  subject { operations.finalize(settings) }

  it "builds a proper schema" do
    find_user = subject[:find_user]

    expect(find_user[:method].call).to eq "get"
    expect(find_user[:path].call(id: 7)).to eq "users/7"
    expect(find_user[:security].call)
      .to eq headers: { "authorization" => "Basic Zm9vOmJhcg==" }
  end
end
