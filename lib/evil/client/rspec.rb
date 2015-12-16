class Evil::Client
  # Defines stubs and matchers to mock and test Evil::Client requests
  #
  # @api private
  #
  module RSpec
    require_relative "rspec/unknown_request_error"
    require_relative "rspec/stubs"
    require_relative "rspec/matchers"
  end
end

::RSpec.configure do |config|
  # Includes the module to RSpec examples
  config.include(Evil::Client::RSpec)

  # Raises an exception in case of unstubbed request
  config.before(:each) do |example|
    unless example.metadata[:stub_client] == false
      allow_any_instance_of(Evil::Client::Adapter)
        .to receive(:send_request) do |adapter, request|
          fail Evil::Client::RSpec::UnknownRequestError.new(request)
        end
    end
  end
end
