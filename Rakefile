# encoding: utf-8
begin
  require "bundler/setup"
rescue LoadError
  puts "You must `gem install bundler` and `bundle install` to run rake tasks"
  exit
end

# Loads bundler tasks
Bundler::GemHelper.install_tasks

# Loads the Hexx::RSpec and its tasks
begin
  require "hexx-suit"
  Hexx::Suit.install_tasks
rescue LoadError
  require "hexx-rspec"
  Hexx::RSpec.install_tasks
end

desc "Runs specs and checks coverage"
task :default do
  system "bundle exec rake test:coverage:run"
end

desc "Runs mutation metric for testing"
task :mutant do
  system "MUTANT=true mutant -r evil-client --use rspec Evil::Client*" \
         " --fail-fast"
end

desc "Exhort all evils"
task :exhort do
  system "MUTANT=true mutant -r evil-client --use rspec Evil::Client*"
end

desc "Runs all the necessary metrics before making a commit"
task prepare: %w(exhort check:inch check:rubocop check:fu)
