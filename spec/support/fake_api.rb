require "webmock/rspec"

# Mocks the remote server when necessary
RSpec.configure do |config|
  config.before(:each, :fake_api) do
    WebMock.disable_net_connect!(allow_localhost: true)
  end
end
