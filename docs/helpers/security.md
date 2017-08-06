Use `security` declaration for the authorization schema.

Whether you use a block or not, the result should be hash with keys `:query` or/and `:headers`.

```ruby
class CatsAPI < Evil::Client
  option :token

  security { { headers: { Authentication: token } } }
end
```

Inside the block we support 3 helper methods as well:

* `basic_auth`
* `token_auth`
* `key_auth`

## Basic Authentication

Use `basic_auth(login, password)` to define [basic authentication following RFC-7617][basic_auth]:

```ruby
class CatsAPI < Evil::Client
  option :login
  option :password

  security { basic_auth(login, password) }
end
```

This declaration with add a header `"Authentication" => "Basic {encoded token}"` to every request. The header is added independenlty of declaration for other [headers][headers].

## Token Authentication

The command `token_auth(token, **options)` allows you to insert a customizable token to any part of the request. Unlike `basic_auth`, you need to provide the token (build, encrypt etc.) by hand.

```ruby
class CatsAPI < Evil::Client
  option :token

  security { token_auth(token) }
  # ...
end
```

By default the token is added to `"Authentication" => {token}` header of the request. You can prepend it with a necessary prefix. For example, you can define a [Bearer token authentication following RFC-6750][bearer]:

```ruby
class CatsAPI < Evil::Client
  option :token

  security { token_auth(token, prefix: "Bearer") }
  # ...
end
```

Instead of headers, you can send a token in a query. In this case the token will be sent under `access_key` without any prefix:

```ruby
class CatsAPI < Evil::Client
  option :token

  security { token_auth(token, inside: :query) }
  # ...
end

# will send a request to a path "..?access_key={token}"
```

## Authentication Using Arbitrary Key

Another option is to authenticate requests with an arbitrary key. This time key-value pair will be added to the selected part (either `headers` or `query`) of the request:

```ruby
class CatsAPI < Evil::Client
  option :token

  security { key_auth :Authentication, token }
  # ...
end
```

When a root setting is reloaded inside a subscope or operation, it totally reload previous declaration. If you need to combine root-level settings with operation-level ones, use either [headers] or a [query].

**Important**: When you define both headers/query, and security settings at the same time, the priority will be given to security. This isn't depend on where (root scope or its sub-scopes) security and headers/query parts are defined. Security settings will always be written over the same headers/query.

```ruby
class CatsAPI < Evil::Client
  security { key_auth :Authentication, "Bar" }

  scope :cats do
    headers  { { Authentication: "Foo" } }
    # will set "Authentication" => "Bar" (not "Foo")
  end
end
```

[basic_auth]: https://tools.ietf.org/html/rfc7617
[bearer]: https://tools.ietf.org/html/rfc6750
[headers]:
[query]: