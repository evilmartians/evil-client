describe "path" do
  before { stub_request :any, /localhost/ }

  let(:client) do
    Evil::Client
      .with(base_url: "https://localhost/v1/")
      .path(:users, 1)
      .path("/sms/3/")
  end

  it "updates path lazily" do
    expect(client).to be_kind_of Evil::Client
  end

  it "builds absolute uri for API base url" do
    expect(client.uri).to eql "https://localhost/v1/users/1/sms/3"
  end

  it "is used by request" do
    client.get

    expect(a_request(:get, %r{v1/users/1/sms/3})).to have_been_made
  end
end
