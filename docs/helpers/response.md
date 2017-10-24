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

In case if you want to implement hierarchical processing of errors from more specific to certain operations or scopes to common errors of whole API, you can call `super!` method from response handler when you want to delegate handling to parent scope:

```ruby
class YourAPI < Evil::Client
  scope :entities do
    operation :create do
      response(409) do |_, _, body|
        data = JSON.parse(body.first)
        case data.dig("errors", 0, "errorId")
        when 35021
          raise YourAPI::AlreadyExists, data.dig("errors", 0, "message")
        else
          super!
        end
      end
    end
  end

  response(409) do |_, _, body|
    data = JSON.parse(body.first)
    raise EbayAPI::Error, data.dig("errors", 0, "message")
  end
end
```

When you use client-specific [middleware], the `response` block will receive the result already processed by the whole middleware stack. The helper will serve a final step of its handling. Its result wouldn't be processed further in any way.

If a remote API will respond with a status, not defined for the operation, the `Evil::Client::ResponseError` will be risen. The exception carries both the response, and all its parts (status, headers, and body).

[rack response]: http://www.rubydoc.info/github/rack/rack/master/file/SPEC#The_Response
[middleware]: