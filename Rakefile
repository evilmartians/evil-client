Bundler.require

Bundler::GemHelper.install_tasks

begin
  require "hexx-suit"
  Hexx::Suit.install_tasks
rescue LoadError
  require "hexx-rspec"
  Hexx::RSpec.install_tasks
end

desc "Run specs and check coverage"
task default: "test:coverage:run"

desc "Run mutation metric for testing"
task :mutant do
  system "MUTANT=1 mutant -r evil-client --use rspec Evil::Client* --fail-fast"
end

desc "Exhort all evils"
task :exhort do
  system "MUTANT=1 mutant -r evil-client --use rspec Evil::Client*"
end

desc "Run all the necessary metrics before making a commit"
task prepare: %w(exhort check:inch check:rubocop check:fu)
