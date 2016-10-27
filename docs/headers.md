Use method `headers` to add several headers to a request. The declaration should have a block with several `attributes` describing corresponding headers.

```ruby
operation :find_cat do |settings|
  headers do
    attribute :token if settings.version > 1
    attribute :id
  end
end
```

The syntax of the attribute declaration is exactly the same as of [Evil::Client::Model][model]. Type constraints and default values are available.

All values for the headers will be taken from a request options:

```ruby
# Sends a request with headers { "id" => 43 }
client.options[:find_cat].call id: 43
```

As a rule, you shouldn't define authorization headers in this way. Use [the security method][security] instead.

Default headers can be declared for every request via anonymous operation. **Notice** that a default headers can be reloaded for specific operation as a whole. New declaration will overwrite all the default set headers instead of merging to them.

```ruby
operation do
  headers do
    attribute :id
  end
end

operation :find_cat do
  headers do
    attribute :cat_id
  end
end

# later at the runtime the following call
# will send request with { "cat_id" => 4 } header only
client.operations[:find_cat].call id: 1, cat_id: 4
```

According to [RFC-2616][rfc-2616], headers are case-insensitive. Inside [middleware][middleware] they are forced to lower case.

For example, while the following declaration is valid by itself, only value from `Foo` option will be sent to remote server:

```ruby
operation do
  headers do
    attribute :foo
    attribute :Foo
  end
end
```

[rfc-2616]: https://www.w3.org/Protocols/rfc2616/rfc2616-sec4.html#sec4.2
[security]:
[model]:
[middleware]:
