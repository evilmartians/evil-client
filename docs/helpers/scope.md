Evil clients use nested scopes to collect definitions and [options], used by single [operations].

## Root Scope

Options and definitions for a root scope should be made in a body of client class:

```ruby
class CatsClient < Evil::Client
  option :user,      proc(&:to_s)
  option :password,  proc(&:to_s)
  option :subdomain, proc(&:to_s)

  validate do
    return if %w[wild domestic].include? subdomain
    errors.add :invalid_subdomain, subdomain: subdomain
  end

  path { "https://#{subdomain}.example.com/" }
  http_method "get"
  security { basic_auth(user, password) }
end
```

These options should be assigned to client instance (all undefined ones will be ignored by the initializer).

```ruby
client = CatsClient.new user: "andy", password: "foo", subdomain: "wild"
client.options # => { user: "andy", password: "foo", subdomain: "wild" }
```

You're free to made definitions on the root level, or leave them to subscopes and concrete operations. The only recommendation is to define base [path] here for all subscopes to share it. It's well worth it to define [security] settings at the root level as well.

## Subscopes

Then you can define named subscope with additional options and definitions. The root options, validators and definitions are inherited by subscopes:

```ruby
class CatsClient < Evil::Client
  # ...

  scope :cats do
    # scope-specific options
    option :version, proc(&:to_i)

    validate { errors.add :wrong_version unless version < 5 }

    # scope-specific redefinition of the root settings
    http_method { version.zero? ? :get : :post }
    path { "cats/v#{version}" }
  end
end
```

```ruby
cats = client.cats(version: 3)
cats.options # => { user: "andy", password: "foo", subdomain: "wild", version: 3 }
```

You can define any number of subscopes at any level of nesting. Every next level will inherit a previous one. There is no difference in DSL for various labels (with a single exclusion for [connection] -- you can assign it to client as a whole, not to a nested scope).

```ruby
class CatsClient < Evil::Client
  # ...
  scope :cats do
    # ...

    scope :video do
      # ...
    end

    scope :books do
      # ...
    end
  end
end
```

Inside a scope you can define the operation -- endpoints to remote API. Any operation belongs to the containing scope and inherits its options, validators and shared definitions (and can reload any).

```ruby
class CatsClient < Evil::Client
  # ...
  scope :cats do
    # ...
    operation :fetch do
      # ...
    end
  end
end
```

## Instantiation

There're several ways to instantiate the scope with options.

A verbose (explicit) style:

```ruby
client.scopes[:cats].new(version: 3)
```

...and a bit shorter version (`call` is an alias for `new`):

```ruby
client.scopes[:cats].(version: 3)
```

...and even shorter (`[]` is an alias for `new` as well):

```ruby
client.scopes[:cats][version: 3]
```

Or just use the name of the scope as a method:

```ruby
client.cats(version: 3)
```

[operations]:
[connection]:
[path]:
[security]:
[options]:
