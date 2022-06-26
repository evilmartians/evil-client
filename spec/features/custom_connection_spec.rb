RSpec.describe "custom connection" do
  let(:conn)     { double call: response }
  let(:response) { [200, { "Foo" => "Bar" }, ["Hello!"]] }
  let(:params)   { { subdomain: "europe", user: "andy", token: "foo" } }
  let(:users)    { Test::Client.new(**params).crm(version: 4).users }

  before do
    load "spec/fixtures/test_client.rb"
    Test::Client.connection = conn
  end

  subject { users.fetch id: 2 }

  it "uses new connection" do
    expect(subject).to eq response
  end
end
