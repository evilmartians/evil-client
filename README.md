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
client = Evil::Client.with base_url: "http://127.0.0.1/v1"
client.uri! # => "http://127.0.0.1/v1"
```

**Roadmap**: 

- [ ] *A client will be initialized by loading swagger specification as well.*
- [ ] *It will be configurable for using several APIs at once.*

### Path building

Use method chain to build RESTful address relative to API root url. Any method whose name doesn't contain `!` or `?` adds a corresponding part to the address. Use brackets `[]` to add a dynamic part of the addres, or a part with dashes:

```ruby
client.users
client.users[1]
client.users[1].sms
client['vip-users'][1].sms
```

### Path finalization

The `#uri!` method call returns the absolute URI:

```ruby
client.users[1].uri!
# => "http://127.0.0.1/v1/users/1"

client.['vip-users'][1].sms.uri!
# => "http://127.0.0.1/v1/vip-users/1/sms"
```

The method doesn't mutate client - you can keep building address. Bangs are used to distinguish parts of address (without bangs) from other instance methods:

```ruby
client.users.uri.uri!
# => "http://127.0.0.1/v1/users/uri"
client.users[1].uri!
# => "http://127.0.0.1/v1/users/1"
```

**Roadmap**:

- [ ] *The finalization will check the path agains API specification (swagger etc.)*.
- [ ] *It will look for an address inside several API*.
- [ ] *It will be possible to select API explicitly by its registered name*.

### Sending requests

Use methods ending with bangs (`#get!`, `#post!`, etc.) to send a corresponding request to the remote API.

Every request except for `#get!` and `#post!` (for example, `#patch!` or `#foo!`) is sent as POST with "_method" parameter.

Other parameters of the request can be provided as method options:

```ruby
client.users[1].sms.get!
client.users[1].sms.post! text: "Hello!"
client.users[1].sms.foo! text: "Hi!" # the same as .post!(_method: :foo, text "Hi!")
```

**Roadmap**:

- [ ] *Before sending the request will be validated against a corresponding API specification (swagger etc.)*.

### Receiving Responses and Handling Errors

Requests return a hash-like structures, exctracted from a body of successful response:

```ruby
result = client.users[1].get!
result.id   # => 1
result.text # => "Hello!"
```

In case of error response (with status 4** or 5**), an exception is raised with error +status+ and +response+ attributes.
Both the source `request` and the hash-like response are available as exception methods:

```ruby
begin
  client.unknown.get!
rescue Evil::Client::ResponseError => error
  error.status    # => 404
  error.request   # => #<Request @type="get" @uri="http://127.0.0.1/v1/users/1"
  error.response  # => #<Response ...>
end
```

### Safe Requests

Methods `try_get!`, `try_post!` etc. send a corresponding request and return `false` in case of error responses:

```ruby
client.unknown.try_get!
# => false
```

### Custom Error Handling

If you need more customized error handling, call methods `#get!` etc. with a block. The block should take one argument where raw error message will be given. The raw message is reseived in a form of [`HTTP::Message`][client-message].

Inside a block you're free to define your own procedure for error handling. The whole method will return the result of the block:

```ruby
client.wrong_address.get! { |error_response| error_response.status }
# => 404
```

**Roadmap**:

- [ ] *A successful responses will also be validated against a corresponding API spec (swagger etc.)*

Usage outside of Rails
----------------------

When using the gem outside of Rails, you have to define a client's `:request_id` explicitly for every single request:

```ruby
client.users[1].get! request_id: "some_id"
```

Alternatively you can configure the `Adapter` class by setting `.id_provider`. It accepts objects that respond to `#value` and returns a string:

```ruby
# Suppose you defined a provider of request id
provider.value => # "custom_id"

# Assign it to Adapter class:
Evil::Client::Adapter.id_provider = id_provider

# Then every request will take request id by sending #value method call to provider
# Both calls are equal:
client.get!
client.get! request_id: "some_id"
```

Roadmap
-------

* client instantiation with several APIs with different `base_url` and `request_id` settings.
* client instantiation from API specifications (swagger)
* client response and request validation using an API specifications (swagger)
* usage of other specification formats (RAML, blueprint etc.)

Compatibility
-------------

Tested under rubies [compatible to MRI 2.2+](.travis.yml).

Uses [RSpec][rspec] 3.0+ for testing and [hexx-suit][hexx-suit] for dev/test tools collection.

Contributing
------------

* Read the [STYLEGUIDE](config/metrics/STYLEGUIDE)
* [Fork the project](https://github.com/evilmartians/evil-client)
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

License
-------

See the [MIT LICENSE](LICENSE).

[mash]: https://github.com/intridea/hashie#mash
[rspec]: http://rspec.org
[hexx-suit]: https://github.com/nepalez/hexx-suit
[swagger]: http://swagger.io
[client-message]: http://www.rubydoc.info/gems/httpclient/HTTP/Message
