RSpec.describe Evil::Client::ResponseError, "#message" do
  let(:error)    { described_class.new schema, settings, response }
  let(:schema)   { "Test::Api.users.get" }
  let(:settings) { :my_settings }
  let(:response) { [422, { "Language" => "en" }, ["something has got wrong"]] }

  subject { error.message }

  it "builds a proper error message" do
    expect(error.message).to eq "remote API responded to Test::Api.users.get" \
                                " with unexpected status 422"
  end

  it "handles proper data" do
    expect(error.schema).to   eq schema
    expect(error.settings).to eq settings
    expect(error.response).to eq response
    expect(error.status).to   eq response[0]
    expect(error.headers).to  eq response[1]
    expect(error.body).to     eq response[2]
  end
end
