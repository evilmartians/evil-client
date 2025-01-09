Use method `headers` to add several headers to a request

```ruby
class CatsClient < Evil::Client
  operation :fetch do
    option :id
    option :language

    headers { { "Accept-Language" => language } }
    # ...
  end
end
```

Remember that you can define header values as a flat array instead of the string. Inside an array all the values are counted as strings.

```ruby
headers { "Language" => ["ru_RU", "charset=utf-8"] }
```

You can define headers bit-by-bit starting from a root scope:

```ruby
class CatsClient < Evil::Client
  option  :charset, default: -> { "utf-8" }
  headers { { "Accept-Charset" => charset } }

  operation :fetch do
    option :id
    option :language

    headers { { "Accept-Language" => language } }
    # ...
  end
end

CatsClient.new(charset: "ascii-1251").fetch(id: 3, language: "en_US")
# This would send a request with the headers:
# { "Accept-Charset" => "ascii-1251", "Accept-Language" => "en_US" }
```

When you redefine some of root options, this redefinition can affects headers:

```ruby
CatsClient.new(charset: "ascii-1251")
          .fetch(id: 3, language: "en_US", charset: "utf-16")

# This would send a request with the headers:
# { "Accept-Charset" => "utf-16", "Accept-Language" => "en_US" }
```

As a rule, you shouldn't define authorization headers in this way. Use [the security helper][security] instead.

**Remember** that eventual collection of request headers is also affected by [security][security] (sets `Authentication`), and [format][format] (sets `Content-Type`) helpers. You can add request headers via [middleware] as well. Finally, the [connection] adds some headers (like `User-Agent`) by its own.

When you define both headers and security settings at the same time, the priority will be given to security. This isn't depend on where (root scope or its sub-scopes) security and headers parts are defined. Security settings will always be written over the same headers.

```ruby
class CatsAPI < Evil::Client
  security { key_auth :Authentication, "Bar" }

  scope :cats do
    headers  { { Authentication: "Foo" } }
    # will set "Authentication" => "Bar" (not "Foo")
  end
end
```

[security]:
[format]: 
[middleware]: 
[connection]: 
