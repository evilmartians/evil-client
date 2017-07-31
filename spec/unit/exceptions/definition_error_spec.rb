RSpec.describe Evil::Client::DefinitionError, "#message" do
  let(:error)    { described_class.new schema, keys, settings, original }
  let(:keys)     { [:path] }
  let(:schema)   { "Test::Api.users.update" }
  let(:settings) { :my_settings }
  let(:original) { "something got wrong" }

  subject { error.message }

  it "builds a proper error message" do
    expect(error.message).to include "failed to resolve path" \
                                     " from Test::Api.users.update schema" \
                                     " for my_settings: something got wrong"
  end
end
