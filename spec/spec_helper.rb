Bundler.require
require 'webmock/rspec'

begin
  require "hexx-suit"
  Hexx::Suit.load_metrics_for(self)
rescue LoadError
  require "hexx-rspec"
  Hexx::RSpec.load_metrics_for(self)
end

# Some mutations can provide infinite loops
if ENV["MUTANT"]
  RSpec.configure do |config|
    config.around { |example| Timeout.timeout(0.5, &example) }
  end
end
