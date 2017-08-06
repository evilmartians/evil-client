RSpec.describe "operation request" do
  before do
    load "spec/fixtures/test_client.rb"
    stub_request(:any, //)
      .to_return(status: status, body: raw_body, headers: {})
  end

  let(:status)   { 200 }
  let(:raw_body) { '{"id":3,"name":"andy"}' }
  let(:users) do
    Test::Client.new(subdomain: "europe", user: "andy", password: "foo")
                .crm(version: 4)
                .users
  end

  shared_examples :valid_client do |details = "properly"|
    it "[processes a response #{details}]" do
      expect(subject).to eq response
    end
  end

  it_behaves_like :valid_client do
    subject { users.fetch(id: 3) }
    let(:response) { [200, {}, [raw_body]] }
  end

  it_behaves_like :valid_client, "using operation-specific handler" do
    subject { users.filter(id: 3) }
    let(:response) { [{ "id" => 3, "name" => "andy" }] }
  end

  context "when handler raises an exception" do
    let(:status) { 404 }

    it "raises the original exception" do
      expect { users.fetch(id: 3) }.to raise_error RuntimeError, /Not found/
    end
  end

  context "when server responded with unexpected status" do
    let(:status) { 403 }

    it "raises Evil::Client::ResponseError" do
      expect { users.fetch(id: 3) }
        .to raise_error Evil::Client::ResponseError, /403/
    end
  end
end
