Human-friendly DSL for writing HTTP(s) clients in Ruby

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

[![Gem Version][gem-badger]][gem]
[![Build Status][travis-badger]][travis]
[![Dependency Status][gemnasium-badger]][gemnasium]
[![Code Climate][codeclimate-badger]][codeclimate]
[![Inline docs][inch-badger]][inch]

## Intro

The gem allows writing http(s) clients in a way inspired by [Swagger][swagger] specifications. It stands away from mutable states and monkey patching when possible. To support multithreading all instances are immutable (though not frozen to avoid performance loss).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'evil-client'
```

And then execute:

```shell
$ bundle
```

Or install it yourself as:

```shell
$ gem install evil-client
```

## Synopsis

The following example gives an idea of how a client to remote API looks like when written on top of `Evil::Client`.

```ruby
require "evil-client"

class CatsClient < Evil::Client
  # Define options for the client's initializer
  option :domain,   proc(&:to_s)
  option :user,     proc(&:to_s)
  option :password, proc(&:to_s)

  # Definitions shared by all operations
  path     { "https://#{domain}.example.com/api" }
  security { basic_auth settings.user, settings.password }

  scope :cats do
    # Scope-specific definitions
    option :version,  default: proc { 1 }
    path { "v#{version}" } # subpath added to root path

    # Operation-specific definitions to update a cat by id
    operation :update do
      option :id,    proc(&:to_i)
      option :name,  optional: true
      option :color, optional: true
      option :age,   optional: true

      let(:data) { options.select { |key, _| %i(name color age).include? key } }
      validate   { errors.add :no_data if data.empty? }

      path        { "cats/#{id}" } # added to root path
      http_method :patch # you can use plain syntax instead of a block
      format      "json"
      body        { options.except(:id, :version) } # [#slice] is available too

      # Parses json response and wraps it into Cat instance with additional
      # parameter
      response 200 do |(status, headers, body)|
        # Suppose you define a model for cats
        Cat.new JSON.parse(body)
      end

      # Parses json response, wraps it into model with [#error] and raises
      # an exception where [ResponseError#response] contains the model istance
      response(400, 422) { |(status, *)| raise "#{status}: Record invalid" }
    end
  end
end

# Instantiate a client with a concrete settings
cat_client = CatClient.new domain:   "awesome-cats",
                           user:     "cat_lover",
                           password: "purr"

# Use verbose low-level DSL to send requests
cat_client.scopes[:cats].new(version: 2)
          .operations[:update].new(id: 4, age: 10, color: "tabby")
          .call # sends request

# Use top-level DSL for the same request
cat_client.cats(version: 2).update(id: 4, age: 10, color: "tabby")

# Both the methods send `PATCH https://awesome-cats.example.com/api/v2/cats/4`
# with a specified body and headers (authorization via basic_auth)
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[codeclimate-badger]: https://img.shields.io/codeclimate/github/evilmartians/evil-client.svg?style=flat
[codeclimate]: https://codeclimate.com/github/evilmartians/evil-client
[dry-initializer]: http://dry-rb.org/gems/dry-initializer
[gem-badger]: https://img.shields.io/gem/v/evil-client.svg?style=flat
[gem]: https://rubygems.org/gems/evil-client
[gemnasium-badger]: https://img.shields.io/gemnasium/evilmartians/evil-client.svg?style=flat
[gemnasium]: https://gemnasium.com/evilmartians/evil-client
[inch-badger]: http://inch-ci.org/github/evilmartians/evil-client.svg
[inch]: https://inch-ci.org/github/evilmartians/evil-client
[swagger]: http://swagger.io
[travis-badger]: https://img.shields.io/travis/evilmartians/evil-client/master.svg?style=flat
[travis]: https://travis-ci.org/evilmartians/evil-client
