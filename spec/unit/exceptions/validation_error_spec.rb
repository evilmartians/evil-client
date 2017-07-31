RSpec.describe Evil::Client::ValidationError, "#message" do
  let(:error)   { described_class.new key, scope, options }
  let(:key)     { :token_present }
  let(:scope)   { "Test::Api.users.update" }
  let(:options) { { id: 3, name: "Andrew" } }

  subject { error.message }

  it "builds a proper error message" do
    # see spec/fixtures/locales/en.yml
    expect(subject).to eq "To update user id:3 you must provide a token"
  end
end
