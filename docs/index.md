Human-friendly DSL for writing HTTP(s) clients in Ruby

[![Logo][evilmartians-logo]][evilmartians]

# About

The gem allows writing http(s) clients in a way close to [Swagger][swagger] specifications. Like in Swagger, you describe models and operations in domain-specific terms. In addition, the gem supports [settings][settings] and [scopes][scopes] for instantiating clients and sending requests in idiomatic Ruby.

The gem stands away from mutable states and monkey patching when possible. To support multithreading, all instances are immutable (though not frozen to avoid performance loss). The gem's DSL is built on top of [dry-initializer][dry-initializer] gem, and supposes heavy usage of [dry-types][dry-types] system of contracts.

For now the top-level DSL supports clients to **json** and **form data** APIs. Because of high variance of XML-based APIs, building their clients require more efforts on a middleware level, which is discussed in the [corresponding topic][xml].

The gem requires ruby 2.2+ and was tested under MRI and JRuby 9+.

# Installation

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

# Example

The following example gives an idea of how a client to remote API looks like when written on top of `Evil::Client` using [dry-types][dry-types]-based contracts.

```ruby
require "evil-client"
require "dry-types"

class CatsClient < Evil::Client
  # describe a client-specific model of cat (the furry pinnacle of evolution)
  class Cat < Evil::Client::Model
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

  # Define a base url using settings
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

    response 200 do |body:, **|
      Cat.new JSON.parse(body) # define that the body should be wrapped to cat
    end

    response 422, raise: true do |body:, **|
      JSON.parse(body) # expect 422 to return json data
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

[swagger]: http://swagger.io
[dry-initializer]: http://dry-rb.org/gems/dry-initializer
[dry-types]: http://dry-rb.org/gems/dry-types
[evilmartians]: https://evilmartians.com
[evilmartians-logo]: https://evilmartians.com/badges/sponsored-by-evil-martians.svg
[settings]:
[scopes]:
[xml]:
