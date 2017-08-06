Use the `option` helper to add options to some scope or operation.

```ruby
class CatsClient < Evil::Client
  # Define options for the client's initializer
  option :domain,   proc(&:to_s)
  option :user,     proc(&:to_s)
  option :password, proc(&:to_s), optional: true
  option :token,    proc(&:to_s), optional: true
  # ...

  scope :cats do
    # Scope-specific options
    option :version, default: proc { 1 }
 
    # Operation-specific options
    operation :fetch do
      option :id, proc(&:to_i)
    end
  end
end
```

The helper is taken from [dry-initializer] gem, so you can see [the gem's documentation][dry-initializer-docs] for the details of its syntax. Notice, that evil-client doesn't support positional arguments (aka `param`-s).

All declarations made at a root scope, or any ancestor scope, are available at the nested levels.
Options assigned during client/scope/operation instantiation are accumulated:

```ruby
client = CatsClient.new domain: "wild", user: "andy"
client.options # => { domain: "wild", user: "andy" }
client.domain  # => "wild"
client.user    # => "andy"

cats = client.cats(version: 3)
cats.options  # => { domain: "wild", user: "andy", version: 3 }

fetch = cats.operations[:fetch].new(id: 7)
fetch.options # => { domain: "wild", user: "andy", version: 3, id: 7 }
```

You can define any assigned option at any level of nesting:

```ruby
fetch = cats.operations[:fetch].new(id: 7, domain: "domestic")
fetch.options # => { domain: "domestic", user: "andy", version: 3, id: 7 }
```

[dry-initializer] https://github.com/dry-rb/dry-initializer
[dry-initializer-docs]: http://dry-rb.org/gems/dry-initializer/
