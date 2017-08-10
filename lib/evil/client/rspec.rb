class Evil::Client
  #
  # Collection of RSpec-related definitions
  #
  module RSpec
    require_relative "rspec/evil_client_schema_matching"
    require_relative "rspec/base_stub"
    require_relative "rspec/allow_stub"
    require_relative "rspec/expect_stub"

    def stub_client_operation(klass = Evil::Client, name = nil)
      AllowStub.new(klass, name)
    end

    def expect_client_operation(klass, name = nil)
      ExpectStub.new(klass, name)
    end

    def unstub_all
      allow(Evil::Client::Container::Operation)
        .to receive(:new)
        .and_call_original
    end
  end
end
