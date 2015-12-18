[WIP] Evil::Client
==================

DSL built on top of `Net::HTTP` to communicate between microservices.

It differs from other HTTP-clients by the following features:

* building requests lazily
* applying some opionated settings:
  - encoding requests to `www-url-form-encoded`
  - authomatically encoding requests to `multipart/form-data` when files being sent
  - following Rails convention for encoding nested body and query
  - expecting responses to be serialized in JSON
  - mapping json responces to [hashies][mash]
* [wip] supporting swagger specifications
* providing RSpec stubs and matchers for the client out of the box

Setup
-----

The library is available as a gem `evil-client`.

Usage
-----

### Initialization

Initialize a new client with base url of a remote API:

```ruby
client = Evil::Client.new "https://localhost:10443/foo"
```

*We will use client with these settings in the examples below.*

**Roadmap**:

- [ ] *A client will be initialized by loading swagger specification as well.*
- [ ] *It will be configurable for using several APIs at once.*

### Request preparation

Use methods `path`, `query`, `body`, and `headers` to customize a request.

You can call them in any order, so that every method adds new data to previously formed request:

```ruby
client
  .path(:users, 1)
  .query(api_key: "foobar")
  .body(baz: { qux: "QUX" })
  .path("/sms/3/")
  .headers(foo: :bar, bar: :baz)
```

This will prepare a request to uri `https://localhost:443/users/1/sms/3?api_key=foobar` with body `baz[qux]=QUX` and headers:

```ruby
{
  "Accept"       => "application/json",
  "Content-Type" => "www-url-form-encoded; charset=utf-8",
  "X-Request-Id" => "some ID taken from 'action_dispatch.request_id' Rack env",
  "Foo"          => "bar", # custom headers
  "Bar"          => "baz"
}
```

The client is designed to work with JSON APIs, that's why default headers are added above.

*When using outside of Rails, request id will be:*
- *either taken from Rack env `HTTP_X_REQUEST_ID` instead of `action_dispatch.request_id`,
- *or skipped when no Rack env is available.*

### Checking the url

The `#uri` method allows to view the current URI of the request:

```ruby
client
  .path(:users, 1)
  .query(meta: { api_key: "foobar" })

client.url
# => "http://localhost/users/1?meta[api_key]=foobar"

client.path(:sms, 3).uri
# => "http://localhost/users/1/sms/3"
```

**Roadmap**:

- [ ] *The finalization will check the path agains API specification (swagger etc.)*.
- [ ] *It will look for an address inside several API*.
- [ ] *It will be possible to select API explicitly by its registered name*.

### Sending requests

To send conventional requests use methods `get!`, `post!`, `patch!`, `put!` and `delete!` with a corresponding query or body.

Arguments of a GET request are added to previously formed query:

```ruby
client
  .path(:users, 1)
  .query(foo: :bar)
  .query(bar: :baz)
  .get! baz: :qux

# will send a GET request to URI: http://localhost/users/1?foo=bar&bar=baz&baz=qux
```

Arguments of a POST, PATCH, PUT and DELETE requests are added to the body. The preformed query is used as well:

```ruby
client
  .path(:users, 1)
  .query(foo: :bar)
  .query(bar: :baz)
  .post! baz: :qux

# will send a POST request to URI: http://localhost/users/1?foo=bar&bar=baz
```

Use the `request!` for non-conventional HTTP method. You can send the method argument only.

Because there is no common convention for custom methods, you can specify body or query explicitly:

```ruby
client
  .path(:users, 1)
  .query(foo: :bar)
  .body(baz: :qux)
  .query(bar: :baz)
  .request! :foo

# will send a FOO request to URI: http://localhost/users/1?foo=bar&bar=baz
```

For example, you can send a request without body:

```ruby
client.path(:users, 1).headers('X-Foo' => 'Bar').request! :head

# will send a HEAD request to URI: http://localhost/users/1
```

**Roadmap**:

- [ ] *Before sending the request will be validated against a correspondin(g API specification (swagger etc.)*.

### Request and Response Encoding

By design, all the request are encoded as either `www-url-form-encoded`, or `multipart/form-data`.

The remote API responces should be encoded as `application/json`.

### Sending nested data

When you send nested data, the keys will be authomatically converted following Rails convention:

```ruby
client
  .path(:users, 1)
  .post! foo: { bar: :BAZ }, qux: [:foo, :bar]

# will send a request with body:
# "foo[bar]=BAZ&qux[]=foo&qux[]=bar"
```

### Sending files

When any value is sent as a file, the request is encoded to `multipart/form-data`. All nested keys are converted to follow rails convention.

```ruby
client
  .path(:users, 1)
  .post! files: [File.new("text.txt"), File.new("image.png")], foo: { bar: :BAZ }

# will send a request with multipart body (notice nested names):
#
# --394u52u3kforiu-ur1\r\n
# Content-Disposition: form-data; name="files[]"; filename="text.txt"\r\n
# Content-Transfer-Encoding: binary\r\n
# ...
# --394u52u3kforiu-ur1\r\n
# Content-Disposition: form-data; name="files[]"; filename="image.png"\r\n
# Content-Transfer-Encoding: binary\r\n
# Content-Type: image/png\r\n
# ...
# --394u52u3kforiu-ur1\r\n
# Content-Disposition: form-data; name="foo[bar]"\r\n
# \r\n
# BAZ\r\n
# --394u52u3kforiu-ur1--\r\n\r\n
```

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
  # Suppose the server responded with text (not a valid JSON!) body "Wrong URL!" and status 404
  error.status    # => 404
  error.request   # => #<Request @method="get" @path="http://localhost/unknown" ...>
  error.response  # => #<Response ...>
  error.content   # => { "error" => "Wrong URL!", "meta" => { "http_code" => 404 } }
end
```

### Safe Requests

Methods without bang: `get`, `post`, `patch`, `put`, `delete`, `request` in case of error response return the hashie.

In case the server responds with JSON body, it adds `[:meta][:http_code]` and `[:error]` keys to the response:

```ruby
result = client.path(:unknown).get!

# Suppose the server responded with body {"text" => "Wrong URL!"} and status 404
result.error?         # => true
result.text           # => "Wrong URL!"
result.meta.http_code # => 404
```

In case the server responds with non-JSON, it wraps the response to the `:error` key:

```ruby
result = client.path(:unknown).get!

# Suppose the server responded with text (not a valid JSON!) body "Wrong URL!" and status 404
result.error?         # => true
result.error          # => "Wrong URL!"
result.meta.http_code # => 404
```

You can always check `error?` over the result of the safe request.

**Roadmap**:

- [ ] *A successful responses will also be validated against a corresponding API spec (swagger etc.)*

## RSpec Helpers

For testing a client of the remote API, the gem provides methods to stub an match requests.

Load them in test environment via:

```ruby
require "evil/client/rspec"
```

This will stub the client so that it **raises exception in responce to any unstubbed request**.

```ruby
client = Evil::Client.new("http://example.com/users")

client.post name: "Ian"
# => #<Evil::Client::RSpec::UnknownRequestError ...>
```

You can switch off with behaviour by tagging some examples with `stub_client: false`:

```ruby
it "should not stub client", stub_client: false do
# ...
end
```

### Stubbing Requests

To stub requests to the client use stubber:

```ruby
allow(client)
  .to receive_request(method, path = nil)
  .with { |req| ... }
  .and_respond(status, body = nil)
```

Its syntax is pretty the same as RSpec original `allow(client).to receive(request).and_return(response)` with subtle differencies:

* `receive_request(method, path = nil)` takes a method and optional path to be stubbed
* `with { |req| ... }` takes a block with actual request to add constraints to
* `and_respond(status, body = nil)` takes an http status and optional body to be received

```ruby
allow(client)
  .to receive_request(:post, "/users/:id")
  .with { |req| req.body.include? name: "Peter" }
  .with { |req| req.query.keys.include? "auth[key]" }
  .and_respond(200, name: "Peter", confirmed: true)

response =
  client
    .path(:users, 1)
    .query(auth: { key: SecureRandom.hex(20) })
    .post name: "Peter"

response.name      # => "Peter"
response.confirmed # => true
```

Unlike the original `with()` that **re-writes** previous constraints, the reloaded `with { |req| ... }` **accumulates** them and stubs only those requests that satisfies all constraints.

Inside the block you can check any part of the request: `body`, `query`, `headers`, `path`.

For `body`, `query` and `headers` you can check equality (`==` or `eql?`), inclusion (`include?`) or list of `keys` that [follows Rails convention][mustermann].

The `path` can be checked for equality (`==` or `eql?`) against Rails path pattern:

```ruby
request.path == "/users/:id"
```

### Matching Requests

Use expectations for clients:

```ruby
expect(client).to receive_request(method, body = nil)
```

The syntax is the same as described in the previous section.

You can count requests, or check their order using the [original RSpec syntax][rspec-mocks]:

```ruby
expect(client).to receive_request(:post, "/users/:id").once.ordered
```

Usually, you don't need `with` in expectations. Instead stub the request and check whether it is called.

If you still do use it, notice that `with { |req| ... }` **unstubs** the request.

This time you should:
* stub http requests via `webmock` or else
* add `and_call_original` to the end of chain

```ruby
require "webmock"

stub_request(:any, //) # use webmock to catch the requests

expect(client)
  .to receive_request(:get, "/cities")
  .with { |req| req.query.include? name: "R'lyeh" }
  .and_call_original # return to original implementation of unstubbed request
```

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
[rspec-mocks]: https://www.relishapp.com/rspec/rspec-mocks/v/3-4/docs/setting-constraints
[mustermann]: https://github.com/rkh/mustermann/blob/master/mustermann-rails/README.md#syntax
