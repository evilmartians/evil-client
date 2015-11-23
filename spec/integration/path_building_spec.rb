describe "remote path building" do

  let(:client)              { Evil::Client.with base_url: "http://localhost/v1/" }
  let(:users_path)          { client.users }
  let(:vip_only_users_path) { client.users[1]["vip-only"] }

  it "builds absolute uri for API base url" do
    expect(client.uri!).to                  eql "http://localhost/v1/"
    expect(users_path.uri!).to              eql "http://localhost/v1/users"
    expect(vip_only_users_path.uri!).to     eql "http://localhost/v1/users/1/vip-only"
    expect(vip_only_users_path.sms.uri!).to eql "http://localhost/v1/users/1/vip-only/sms"
  end

  it "updates path lazily" do
    expect(vip_only_users_path).to be_kind_of Evil::Client
  end

  it "responds to any method without bang" do
    expect(client).to respond_to :foo
  end
end
