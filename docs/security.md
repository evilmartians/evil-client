Use `security` declaration for the authorization schema. Inside the block you have access to 3 methods:
* `basic_auth`
* `token_auth`
* `key_auth`

## Basic Authentication

Use `basic_auth(login, password)` to define [basic authentication following RFC-7617][basic_auth]:

```ruby
operation :find_cat do |settings|
  security do
    basic_auth settings.login, settings.password
  end
end
```

This declaration with add a header `"Authentication" => "Basic {encoded token}"` to every request. The header is added independenlty of declaration for other [headers][headers].

## Token Authentication

The command `token_auth(token, **options)` allows you to insert a customizable token to any part of the request. Unlike `basic_auth`, you need to provide the token (build, encrypt etc.) by hand.

```ruby
operation :find_cat do |settings|
  security do
    token_auth settings.token
  end
end
```

By default the token is added to `"Authentication" => {token}` header of the request. You can prepend it with a necessary prefix. For example, you can define a [Bearer token authentication following RFC-6750][bearer]:

```ruby
operation :find_cat do |settings|
  security do
    token_auth settings.token, prefix: "Bearer"
  end
end
```

Instead of headers, you can send a token in either request body, or a query. In this case the token will be sent under `access_key` ignoring a prefix:

```ruby
operation :find_cat do |settings|
  path { "/cats" }
  security do
    token_auth settings.token, using: :query
  end
end

# will send a request to "../cats?access_key={token}"
```

## Authentication Using Arbitrary Key

The most customizeable option is to authenticate requests with an arbitrary key. This time key-value pair will be added to the selected part (`headers`, `body`, or `query`) of the request:

```ruby
operation :find_cat do |settings|
  path { "/cats" }
  security do
    key_auth :accss_key, settings.token, using: :query
  end
end
```

## Authentication Using Several Schemes

You can define several schemes for the same request. All of them will be applied at once:

```ruby
operation :find_cat do |settings|
  security do
    basic_auth settings.login, settings.password
    token_auth settings.token, using: :query
  end
end
```

Moreover, you can declare shared authentication by default, and either update, or reload it for a specific operation:

```ruby
operation do |settings|
  security { basic_auth settings.login, settings.password }
end

operation :find_cat do |settings|
  security { token_auth settings.token, using: :query } # added to default security
end

operation :find_cats do |settings|
  security { token_auth settings.token } # reloads default "Authentication" header
end
```


[basic_auth]: https://tools.ietf.org/html/rfc7617
[bearer]: https://tools.ietf.org/html/rfc6750
[headers]:
[body]:
[query]: