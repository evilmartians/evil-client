Use `settings` to parameterize an instance of the client.

Inside the block you can define both `param`s and `option`s for a client constructor. See [dry-initializer docs][dry-initializer] for detailed description of the methods' syntax.

```ruby
require "evil-client"
require "dry-types"

class CatsClient < Evil::Client
  settings do
    param  :roor_url
    option :version,  type: Dry::Types["coercible.int"], default: proc { 1 }
    option :login,    type: Dry::Types["strict.string"] # required
    option :password, type: Dry::Types["strict.string"] # required
  end
end
```

Now you can initialize a client:

```ruby
client = CatsClient.new "https://cats.example.com",
                        login: "cats_lover",
                        password: "purr"
```

A container with assigned settings will be passed to blocks declaring [base_url][base_url], [connection][connection], and [operations][operation].

[base_url]:
[connection]:
[operation]:
[dry-initializer]: http://dry-rb.org/gems/dry-initializer
