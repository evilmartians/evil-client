# Evil::Client

Human-friendly DSL for writing HTTP(s) clients in Ruby

<a href="https://evilmartians.com/">
<img src="https://evilmartians.com/badges/sponsored-by-evil-martians.svg" alt="Sponsored by Evil Martians" width="236" height="54"></a>

[![Gem Version][gem-badger]][gem]
[![Build Status][travis-badger]][travis]
[![Dependency Status][gemnasium-badger]][gemnasium]
[![Code Climate][codeclimate-badger]][codeclimate]
[![Inline docs][inch-badger]][inch]

## Intro

The gem allows writing http(s) clients in a way close to [Swagger][swagger] specifications. Like in Swagger, you need to specify models and operations in domain-specific terms. In addition, the gem supports settings and scopes for instantiating clients and sending requests in idiomatic Ruby.

The gem stands away from mutable states and monkey patching when possible. To support multithreading all instances are immutable (though not frozen to avoid performance loss). Its DSL is backed on top of [dry-initializer][dry-initializer] gem, and supposes heavy usage of [dry-types][dry-types] system of contracts.

For now the DSL supports clients to **json** and **form data** APIs out of the box. Because of high variance of XML-based APIs, building corresponding clients require more efforts on a middleware level.

[swagger]: http://swagger.io
[dry-initializer]: http://dry-rb.org/gems/dry-initializer
[dry-types]: http://dry-rb.org/gems/dry-types

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

The following example gives an idea of how a client to remote API looks like when written on top of `Evil::Client` using [dry-types][dry-types]-based contracts.

```ruby
require "evil-client"
require "dry-types"

class CatsClient < Evil::Client
  # describe a client-specific model of cat (the furry pinnacle of evolution)
  class Cat < Evil::Struct
    attribute :name,  type: Dry::Types["strict.string"], optional: true
    attribute :color, type: Dry::Types["strict.string"]
    attribute :age,   type: Dry::Types["coercible.int"], default: proc { 0 }
  end

  # Define settings the client initialized with
  # The settings parameterizes operations when necessary
  settings do
    param  :domain,   type: Dry::Types["strict.string"] # required!
    option :version,  type: Dry::Types["coercible.int"], default: proc { 0 }
    option :user,     type: Dry::Types["strict.string"] # required!
    option :password, type: Dry::Types["strict.string"] # required!
  end

  # Define a base url using
  base_url do |settings|
    "https://#{settings.domain}.example.com/api/v#{settings.version}/"
  end

  # Definitions shared by all operations
  operation do |settings|
    security { basic_auth settings.user, settings.password }
  end

  # Operation-specific definition to update a cat by id
  # This provides low-level DSL `operations[:update_cat].call`
  operation :update_cat do |settings|
    http_method :patch
    path { |id:, **| "cats/#{id}" } # id will be taken from request parameters

    body format: "json" do
      attribute :name,  optional: true
      attribute :color, optional: true
      attribute :age,   optional: true
    end

    # Parses json response and wraps it into Cat instance with additional
    # parameter
    response 200, format: :json, type: Cat do
      attribute :success
    end

    # Parses json response, wraps it into model with [#error] and raises
    # an exception where [ResponseError#response] contains the model istance
    response 422, format: :json, raise: true do
      attribute :error
    end

    # Takes raw body and converts it into the hashie
    response 404, raise: true do |body|
      Hashie::Mash.new error: body
    end
  end

  # Add top-level DSL
  scope :cats do
    scope do |id|
      def find(**data)
        operations[:update_cat].call(id: id, **data)
      end
    end
  end
end

# Instantiate a client with concrete settings
cat_client = CatClient.new "awesome-cats", # domain
                           version: 1,
                           user: "cat_lover",
                           password: "purr"

# Use low-level DSL to send requests
cat_client.operations[:update_cat].call id:    4,
                                        age:   10,
                                        name:  "Agamemnon",
                                        color: "tabby"

# Use top-level DSL for the same request
cat_client.cats[4].call(age: 10, name: "Agamemnon", color: "tabby")

# Both the methods send `PATCH https://awesom-cats.example.com/api/v1/cats/7`
# with a specified body and headers (authorization via basic_auth)
```

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

[codeclimate-badger]: https://img.shields.io/codeclimate/github/evilmartians/evil-client.svg?style=flat
[codeclimate]: https://codeclimate.com/github/evilmartians/evil-client
[gem-badger]: https://img.shields.io/gem/v/evil-client.svg?style=flat
[gem]: https://rubygems.org/gems/evil-client
[gemnasium-badger]: https://img.shields.io/gemnasium/evilmartians/evil-client.svg?style=flat
[gemnasium]: https://gemnasium.com/evilmartians/evil-client
[inch-badger]: http://inch-ci.org/github/evilmartians/evil-client.svg
[inch]: https://inch-ci.org/github/evilmartians/evil-client
[travis-badger]: https://img.shields.io/travis/evilmartians/evil-client/master.svg?style=flat
[travis]: https://travis-ci.org/evilmartians/evil-client
