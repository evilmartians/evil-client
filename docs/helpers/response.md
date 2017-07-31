For every operation you have to describe all expected responses and how they should be processed.

Use the `response` method with expected http response status(es):

```ruby
class CatsAPI < Evil::Client
  response 200, 201, 404, 422, 500
end
```

These definitions are inherited by all subscopes/operations. You can reload them later for every separate status. The definition tells a client to accept responses with given statuses, and to return [rack-compatible response][rack response] as is.

Using a block, you can handle the response in a way you need. For example, the following code will extract and parse json body only.

```ruby
response 200 do |(_status, _headers, *body)|
  JSON.parse(body.first) if body.any?
end
```

**Remember** that in rack responses body is always wrapped to array (enumerable structure).

Do you best to either wrap a response to your domain model, or raise a specific exception:

```ruby
response 200 do |(_status, _headers, *body)|
  Cat.new(JSON.parse(body.first)) if body.any?
end

response 400, 422 do |_status, *|
  raise "#{status}: Record invalid"
end
```

When you use client-specific [middleware], the `response` block will receive the result already processed by the whole middleware stack. The helper will serve a final step of its handling. Its result wouldn't be processed further in any way.

If a remote API will respond with a status, not defined for the operation, the `Evil::Client::ResponseError` will be risen. The exception carries both the response, and all its parts (status, headers, and body).

[rack response]: http://www.rubydoc.info/github/rack/rack/master/file/SPEC#The_Response
[middleware]: