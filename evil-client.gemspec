Gem::Specification.new do |gem|
  gem.name     = "evil-client"
  gem.version  = "3.2.0"
  gem.author   = ["Andrew Kozin (nepalez)", "Ravil Bairamgalin (brainopia)"]
  gem.email    = ["andrew.kozin@gmail.com", "nepalez@evilmartians.com"]
  gem.homepage = "https://github.com/evilmartians/evil-client"
  gem.summary  = "Human-friendly DSL for building HTTP(s) clients in Ruby"
  gem.license  = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]

  gem.required_ruby_version = ">= 2.6"

  gem.add_runtime_dependency "dry-initializer", ">= 2.1"
  gem.add_runtime_dependency "mime-types", ">= 3.1"
  gem.add_runtime_dependency "rack", ">= 2"
  gem.add_runtime_dependency "tram-policy", ">= 0.3.1", "< 3"
  gem.add_runtime_dependency "base64", ">= 0.2.0", "< 0.3"

  gem.add_development_dependency "rake", ">= 10"
  gem.add_development_dependency "rspec", ">= 3.0"
  gem.add_development_dependency "rspec-its"
  gem.add_development_dependency "rubocop"
  gem.add_development_dependency "timecop"
  gem.add_development_dependency "webmock"
end
