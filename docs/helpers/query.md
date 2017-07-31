Use `query` helper to add some data to the request query. The helper should provide a hash, either nested or not.

```ruby
class CatsClient < Evil::Client
  # ...
  operation :cats do
    # ...
    operation :fetch do
      option :language, default: proc { "en_US" }
      # ...
      query { { language: language } }
    end
  end
end

# Later at the runtime it will include query to the fetch request "..?language=en_US"
CatsClient.new.cats.fetch
```

When you add query in nested scopes/operations, it updates upper-level definitions, using deep merge when possible (both queries should have compatible structures):

```ruby
class CatsClient < Evil::Client
  option :language, default: proc { "en_US" }
  query { { accept: { language: language } } }

  operation :cats do
    option :charset, default: proc { "utf-8" }
    query { { accept: { charset: charset } } }
    # ...
    operation :fetch do
      # ...
    end
  end
end

# Later at the runtime it will include query to any cats operation:
# ...?accept[language]=en_US&accept[charset]=utf-8
CatsClient.new.cats.fetch
```

**Remember** that like [headers], the final query affected by [security][security] (for example, it can define `basic_auth`) settings. 

When you define both query and security settings at the same time, the priority will be given to security. This isn't depend on where (root scope or its sub-scopes) security and query parts are defined. Security settings will always be written over the same query.

```ruby
class CatsAPI < Evil::Client
  security { key_auth :basic_auth, "Bar" }

  cats do
    query { { basic_auth: "Foo" } }
    # will send requests to ...?basic_auth=Bar
  end
end
```

[rfc-3986]: https://tools.ietf.org/html/rfc3986
[security]:
[headers]: