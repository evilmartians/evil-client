Gem::Specification.new do |gem|

  gem.name        = "evil-client"
  gem.version     = "0.0.1-alpha"
  gem.author      = ["Andrew Kozin"]
  gem.email       = ["nepalez@evilmartians.com"]
  gem.homepage    = "https://github.com/evilmartians/evil-client"
  gem.summary     = "DSL for dealing with remote REST Registry"
  gem.license     = "MIT"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = gem.files.grep(/^spec/)
  gem.extra_rdoc_files = Dir["README.md", "LICENSE", "CHANGELOG.md"]

  gem.required_ruby_version = ">= 2.2"

  gem.add_runtime_dependency "httpclient", "~> 2.6"

  gem.add_development_dependency "hexx-rspec", "~> 0.5"

end
