Bundler.require
Hexx::Suit.load_metrics_for(self)

# Some mutations can provide infinite loops
if ENV["MUTANT"]
  RSpec.configure do |config|
    config.around { |example| Timeout.timeout(0.5, &example) }
  end
end
