Use `base_url` to define a base url, [operation paths][path] are relative to.

You can use [`settings`][settings] as the only argument of the declaration block.

```ruby
require "evil-client"
require "dry-types"

class CatsClient < Evil::Client
  settings do
    option :version, type: Dry::Types["coercible.int"], default: proc { 1 }
  end
  
  base_url do |settings|
    "https://cats.example.com/v#{settings.version}"
  end
  
  operation :find_cats do |_settings|
    http_method :get
    path { "cats" }
  end
end
```

After a client's instantiation...

```ruby
client = CatsClient.new version: 3
```

...the following call will send a request `GET https://example.com/v3/cats`.

```ruby
client.operations[:find_cat].call
```

[settings]:
[path]:
