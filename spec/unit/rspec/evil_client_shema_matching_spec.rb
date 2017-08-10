RSpec.describe "rspec matcher :evil_client_schema_matching" do
  before { load "spec/fixtures/test_client.rb" }

  let(:client) { Test::Client.new(subdomain: "foo", user: "bar", token: "baz") }
  let(:users)  { client.crm(version: 7).users }
  let(:schema) { users.operations[:fetch].schema }

  it "passes when schema matches a client" do
    expect(schema).to evil_client_schema_matching(Test::Client)
  end

  it "fails when schema not matches a client superclass" do
    expect(schema).to evil_client_schema_matching(Evil::Client)
  end

  it "fails when schema not matches a client" do
    expect(schema).not_to evil_client_schema_matching(String)
  end

  it "passes when schema matches client and full path" do
    expect(schema)
      .to evil_client_schema_matching(Test::Client, "crm.users.fetch")
  end

  it "failse when schema matches client but not a full path" do
    expect(schema).not_to evil_client_schema_matching(Test::Client, "crm.users")
  end

  it "passes when schema matches client and path regex" do
    expect(schema).to evil_client_schema_matching(Test::Client, /crm\.users/)
  end

  it "passes when schema matches client and path regex" do
    expect(schema)
      .not_to evil_client_schema_matching(Test::Client, /crm\.fetch/)
  end
end
