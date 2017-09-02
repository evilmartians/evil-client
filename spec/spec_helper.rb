begin
  require "pry"
rescue LoadError
  nil
end

require "bundler/setup"
require "webmock/rspec"
require "rspec/its"
require "timecop"
require "tempfile"
require "evil/client"
require "evil/client/rspec"

require_relative "support/fixtures_helper"

RSpec.configure do |config|
  config.order = :random
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true

  config.before(:each) do
    # Stub all requests using webmock
    stub_request(:any, //)
    # Prepare the Test namespace for constants defined in specs
    module Test; end
    # Load translations
    I18n.load_path += Dir["spec/fixtures/locales/*.yml"]
  end

  config.after(:each) do
    Object.send :remove_const, :Test
  end
end
