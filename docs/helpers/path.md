Use `path` helpers to define operation's path for every operation.

As a rule, you should start from defining root path at the very root of your client, and then complement it at any level of scoping:

```ruby
class CatsClient < Evil::Client
  # ...
  option :domain
  path { "https://#{domain}.example.com" }
  # ...

  scope :cats do
    path "cats" # relative to the root's one

    operation :fetch do
      option :id # relative to the cats' one
      path { id }
      # ...
    end
  end
end
```

Above declaration will send fetch requests to "https://{domain}.example.com/cats/{id}", for example:

```ruby
CatsClient.new(domain: "domestic").cats.fetch(37)
# "https://domestic.example.com/cats/37"
```

In practice it is the structure of API paths that will "dictate" the structure of your client's scopes.

The path should be defined for every operation, otherwise calling it will cause an exception.

**Notice**. You havent include query to the path. Use [query] helper method instead to define it.

[query]:
