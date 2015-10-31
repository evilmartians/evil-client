describe "remote path building" do

  let(:client) { Evil::Client.with base_url: "http://localhost/v1/" }
  let(:path)   { client.users[1]["vip-only"] }

  it "builds absolute uri for API base url" do
    expect(client.uri!).to   eql "http://localhost/v1/"
    expect(path.uri!).to     eql "http://localhost/v1/users/1/vip-only"
    expect(path.sms.uri!).to eql "http://localhost/v1/users/1/vip-only/sms"
  end

  it "updates path lazily" do
    expect(path).to be_kind_of Evil::Client
  end

  it "responds to any method without bang" do
    expect(client).to respond_to :foo
  end

  it "doesn't respond to undefined methods with ! or ?" do
    expect(client).not_to respond_to :foo!
    expect(client).not_to respond_to :foo?
  end
end
