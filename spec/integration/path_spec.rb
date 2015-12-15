describe "path" do
  before { stub_request :any, // }

  let(:client) do
    Evil::Client.new("localhost").path(:users, 1).path("/sms/3/")
  end

  it "updates path lazily" do
    expect(client).to be_kind_of Evil::Client
  end

  context "without protocol" do
    it "builds absolute uri for API base url" do
      expect(client.uri).to eql "http://localhost/users/1/sms/3"
    end
  end

  context "with complex base_url" do
    let(:client) do
      Evil::Client.new("localhost/v1").path(:users, 1).path("/sms/3/")
    end

    it "builds absolute uri for API base url" do
      expect(client.uri).to eql "http://localhost/v1/users/1/sms/3"
    end
  end

  context "with protocol" do
    let(:client) do
      Evil::Client.new("https://localhost/v1").path(:users, 1).path("/sms/3/")
    end

    it "it uses the protocol" do
      expect(client.uri).to eql "https://localhost/v1/users/1/sms/3"
    end
  end
end
