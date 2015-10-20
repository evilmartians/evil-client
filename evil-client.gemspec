$:.push File.expand_path("../lib", __FILE__)
require "evil/client/version"

Gem::Specification.new do |gem|

  gem.name        = "evil-client"
  gem.version     = Evil::Client::VERSION.dup
  gem.author      = ["Andrew Kozin"]
  gem.email       = ["nepalez@evilmartians.com"]
  gem.homepage    = "https://github.com/evilmartians/evil-client"
  gem.summary     = "DSL for dealing with REST resources declared by Swagger"

  gem.files            = `git ls-files`.split($INPUT_RECORD_SEPARATOR)
  gem.test_files       = Dir["spec/**/*.rb"]
  gem.extra_rdoc_files = Dir["README.md", "LICENSE"]
  gem.require_paths    = ["lib"]

  gem.required_ruby_version = ">= 1.9.3"

  gem.add_runtime_dependency "swagger-core"

  gem.add_development_dependency "hexx-rspec"

end # Gem::Specification
