Define [http method] for sending a request using the `http_method` helper.

```ruby
operation :fetch do
  http_method :get
  # ...
end
```

As usual, you have access to current options. This can be useful to make the method dependent from either a version, or another variation of API.

```ruby
operation :fetch do
  # ...
  option :version, proc(&:to_i)

  http_method { version > 2 ? :post : :get }
  # ...
end
```

The definition can be reloaded at any level of scoping.

Following [RFC 7231], we support only valid methods (they could be set as case-insensitive stringified object):

- GET
- POST
- PUT
- PATCH
- DELETE
- OPTIONS
- HEAD
- TRACE
- CONNECT

Setting http method to another value, or missing it, will cause an exception.

[http method]: 
[RFC 7231]: https://tools.ietf.org/html/rfc7231