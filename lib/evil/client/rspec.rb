class Evil::Client
  # Defines stubs and matchers to mock and test Evil::Client requests
  #
  # @api private
  #
  module RSpec
    require_relative "rspec/stubs"
  end
end

# Includes the module to RSpec examples
::RSpec.configure { |config| config.include(Evil::Client::RSpec) }
