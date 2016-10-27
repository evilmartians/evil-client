For every operation you have to describe all expected responses and how they should be processed.

Use the `response` method with anexpected http response status(es):

```ruby
operation :find_cat do
  # ...
  response 200, 201
end
```

This definition tells a client to accept responses with given statuses, and to return an instance of `Rack::Response`.

```ruby
client.operations[:find_cat].call
# => #<Rack::Response @code=200 ...>
```

## Data Coersion

Instead of returning a raw rack response, you can coerce it using a block. The block will take 3 options, namely the response, its body and headers:

```ruby
operation :find_cat do |settings| # remember that you have access to settings
  # ...
  response 200 do |response:, body:, headers:|
    JSON.parse(body) if settings.format == "json"
  end
end

# later at a runtime
client.operations[:find_cat].call
# => { name: "Bastet", age: 10 }
```



## Raising Exceptions

When processing responces with error statuses you may need to raise an exception instead of returning values. Do this using option `raise: true` 

```ruby
operation :find_cat do
  # ...
  response 422, raise: true
end
```

This time the operation will raise a `Evil::Client::ResponseError` (inherited from the `RuntimeError`). The exception carries a rack response:

```ruby
begin
  client.operations[:find_cat].call
rescue Evil::Client::ResponseError => error
  error.response
  # => #<Rack::Response @code=422 ...>
end
```

Like before, you can add a block to handle the response. In this case an exception will carry a result of the block.

## Unexpected Responses

In case the server responded with undefined status, the operation raises `Evil::Client::UnexpectedResponseError` (inherited from the `RuntimeError`) that carries a rack response just like the `Evil::Client::ResponseError` before.

Notice that you can declare default responses using anonymous `operation {}` syntax. Only those responces that are declared neither by default, nor for a specific operation, will cause unexpected response behaviour.
