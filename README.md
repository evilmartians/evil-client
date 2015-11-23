[WIP] Evil::Client
==================

DSL for dealing with remote REST APIs

Setup
-----

The library is available as a gem `evil-client`.

Usage
-----

### Configuring

Inside Rails application, define a request ID for a remote API:

```ruby
@todo
```

### Initialization

Initialize a new client with `base_url` of a remote API:

```ruby
client = Evil::Client.with base_url: "http://localhost"
client.uri! # => "http://localhost"
```

We will use this client in all the examples below.

**Roadmap**:

- [ ] *A client will be initialized by loading swagger specification as well.*
- [ ] *It will be configurable for using several APIs at once.*

### Request preparation

Use methods `path`, `query` and `headers` to customize a request. You can call them in any order, so that every method adds new data to previously formed request:

```ruby
client
  .path(:users, 1)
  .query(api_key: "foobar")
  .path("/sms/3/")
  .headers(foo: :bar, bar: :baz)
```

This will prepare a request to uri `http://localhost/users/1/sms/3?api_key=foobar` with headers:

```ruby
{
  "Accept"       => "application/json",
  "Content-Type" => "application/json; charset=utf-8",
  "X-Request-Id" => "some ID taken from 'action_dispatch.request_id' Rack env",
  "Foo"          => "bar", # custom headers
  "Bar"          => "baz"
}
```

The client is designed to work with JSON APIs, that's why default headers are added above.

*When using outside of Rails, request id will be:*
- *either taken from Rack env `HTTP_X_REQUEST_ID` instead of `action_dispatch.request_id`,
- *or skipped when no Rack env is available.*

### Checking the uri

The `#uri` method allows to view the current uri of the request without a query:

```ruby
client
  .path(:users, 1)
  .query(api_key: "foobar")

client.uri
# => "http://localhost/users/1"

client.path(:sms, 3).uri
# => "http://localhost/users/1/sms/3"
```

**Roadmap**:

- [ ] *The finalization will check the path agains API specification (swagger etc.)*.
- [ ] *It will look for an address inside several API*.
- [ ] *It will be possible to select API explicitly by its registered name*.

### Sending requests

To send conventional requests use methods `get!`, `post!`, `patch!`, `put!` and `delete!` with a corresponding query or body.

In a GET request the arguments will be added to previously formed query:

```ruby
client
  .path(:users, 1)
  .query(foo: :bar)
  .query(bar: :baz)
  .get! baz: :qux

# will send a GET request to URI: http://localhost/users/1?foo=bar&bar=baz&baz=qux
```

In a POST request the arguments will be sent as a body. The preformed query is used as well:

```ruby
client
  .path(:users, 1)
  .query(foo: :bar)
  .query(bar: :baz)
  .post! baz: :qux

# will send a POST request to URI: http://localhost/users/1?foo=bar&bar=baz
# with a body "baz=qux"
```

Other requests are formed like the POST with a corresponding `_method` added to the body:

```ruby
client
  .path(:users, 1)
  .query(foo: :bar)
  .query(bar: :baz)
  .patch! baz: :qux

# will send a POST request to URI: http://localhost/users/1?foo=bar&bar=baz
# with a body "baz=qux\n_method=patch"
```

Use the `request!` for non-conventional HTTP method with an additional first argument:

```ruby
client
  .path(:users, 1)
  .query(foo: :bar)
  .query(bar: :baz)
  .request! :foo, baz: :qux

# will send a POST request to URI: http://localhost/users/1?foo=bar&bar=baz
# with a body "baz=qux\n_method=foo"
```

**Roadmap**:

- [ ] *Before sending the request will be validated against a corresponding API specification (swagger etc.)*.

### Receiving Responses and Handling Errors

In case a server responds with success, all methods return a content serialized to extended hash-like structures ([Hashie::Mash][mash]).

```ruby
result = client.path(:users, 1).get!

result[:id]   # => 1
result.id     # => 1
result[:text] # => "Hello!"
result.text   # => "Hello!"
result.to_h   # => { "id" => "1", "text" => "Hello!" }
```

In case a server responds with error (status 4** or 5**), there're two ways of error handling.

### Unsafe Requests

Methods with bang `!` raises an exception in case of error response.

Both the source `request` and the hash-like `response` are available as exception methods:

```ruby
begin
  client.path(:unknown).get!
rescue Evil::Client::ResponseError => error
  error.status    # => 404
  error.request   # => #<Request @type="get" @path="http://localhost/unknown" ...>
  error.response  # => #<Response ...>
end
```

### Safe Requests

Methods without bang: `get`, `post`, `patch`, `put`, `delete`, `request` in case of error response return the hashie.

In case the server responds with JSON body, it adds `[:meta][:http_code]` and `[:error]` keys to the response:

```ruby
result = client.path(:unknown).get!

# Suppose the server responded with body {"text" => "Wrong URL!"} and status 404
result.to_h
# => { "text" => "Wrong URL!", "error" => true, "meta" => { "http_code" => 404 } }
result.error? # => true
```

In case the server responds with non-JSON, it wraps the response to the `:error` key:

```ruby
result = client.path(:unknown).get!

# Suppose the server responded with text (not a valid JSON!) body "Wrong URL!" and status 404
result.to_h
# => { "error" => "Wrong URL!", "meta" => { "http_code" => 404 } }
result.error? # => true
```

You can always check `error?` over the result of the safe request.

**Roadmap**:

- [ ] *A successful responses will also be validated against a corresponding API spec (swagger etc.)*

Compatibility
-------------

Tested under rubies [compatible to MRI 2.2+](.travis.yml).

Uses [RSpec][rspec] 3.0+ for testing.

Contributing
------------

* [Fork the project](https://github.com/evilmartians/evil-client)
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am 'Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

License
-------

See the [MIT LICENSE](LICENSE).

[mash]: https://github.com/intridea/hashie#mash
[rspec]: http://rspec.org
[swagger]: http://swagger.io
[client-message]: http://www.rubydoc.info/gems/httpclient/HTTP/Message
