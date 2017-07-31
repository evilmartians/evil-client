Use helper `link` to provide reference to online docs for the current operation.

```ruby
class CatsAPI < Evil::Client
  option :version

  # ...
  link { "https://my_client.example.com/docs/v#{version}" }

  scope :cats do
    # ...

    operation :fetch
      # ...
      link "https://my_client.example.com/api/docs/v#{version}#fetch_cat"
    end
  end
end
```

The link will be available for an instance of a corresponding scope/operation.

```ruby
client = CatsAPI.new version: 3
cats   = client.cats
fetch  = cats.operations[:fetch]

client.link # => "https://my_client.example.com/docs/v3"
cats.link   # => "https://my_client.example.com/docs/v3"
fetch.link  # => "https://my_client.example.com/docs/v3#fetch"
```

**Important:** Unlike [path], method link not chained but reloaded by any nested definition. This is because documentation not necessary to follow path nesting (in above example the documentation for "fetch" refers to a specific anchor, not to a subpath).

[path]:
