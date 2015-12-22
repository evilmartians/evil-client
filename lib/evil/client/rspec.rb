# Gem-speficic RSpec mocks and expectations
#
# @example
#   allow(client)
#     .to receive_request(:get, '/foo/bar')
#     .where { |req| req.query.include? foo: :BAR }
#     .and_call_original
#
#   expect(client).to receive_request(:get, '/foo/bar')
#
#   client.path(:foo, :bar).get foo: :BAR
#
#   expect(client).to have_received_request(:get, '/foo/bar')
#
module Evil::Client::RSpec

  require_relative "rspec/stub_error"
  require_relative "rspec/request_mock"
  require_relative "rspec/stub"

  # Redefines stub to use clients as if they were adapters
  #
  # @param [Object] value
  #
  # @return [undefined]
  #
  def allow(value)
    super coerce_evil_client(value)
  end

  # Redefines expectation to use clients as if they were adapters
  #
  # @param [Object] value
  #
  # @return [undefined]
  #
  def expect(value = nil)
    if block_given?
      super() { yield }
    else
      super coerce_evil_client(value)
    end
  end

  # Provides gem-specific variant of `receive` mock matcher
  #
  # @param [#to_s] method The method of the request to be stubbed or checked
  # @param [String, Regexp, nil] path The path to be checked
  #
  # @return [RSpec::Mock::Matchers::Receive]
  #
  def receive_request(method, path = nil)
    receive(:send_request)
      .tap { |mock| mock.extend Stub }
      .with(RequestMock.new(method, path))
  end

  private

  def coerce_evil_client(value)
    value.is_a?(Evil::Client) ? value.adapter : value
  end
end

# Checks whether the request satisfies all given conditions
RSpec::Matchers.define :satisfy_all do |conditions|
  match do |request|
    conditions.inject(true) do |result, condition|
      result && condition.call(request)
    end
  end
end

RSpec.configure do |config|
  # Includes the module to RSpec examples
  config.include(Evil::Client::RSpec)

  # Raises an exception in case of unstubbed request
  config.before(:each) do |example|
    unless example.metadata[:stub_client] == false
      allow_any_instance_of(Evil::Client::Adapter)
        .to receive(:send_request) do |_, request|
          fail Evil::Client::RSpec::StubError.new request
        end
    end
  end
end
