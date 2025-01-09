Operation defines a specific request to a remote API with some helpers to process its responses.

To specify an operation, you should define the following parts:

- [options] of the request sender
- http(s) [path] to the remote server
- [http method] for sending requests
- [security] definitions describing what credentials the request should carry
- http [headers] to include into the request (along with security-related ones)
- request [query] to be added to the request path (along with security-related)
- a [content][body] of the request and a [format][body] describing the content should be formatted
- a set of [middleware] that should be added to the remote [connection]
- a set of expected [responses] with corresponding handlers

An operation is specified with a unique name inside the corresponding [scope].

You can add it to the root of the client, or to any subscope:

```ruby
class CatsClient < Evil::Client
  # Returns current information about the client
  operation :info do
    # ...
  end

  scope :cats do
    # ...

    # Fetches information about a specific cat
    operation :fetch do
      # ...
    end
  end
end
```

Operation-specific definitions should be made inside the block. They will affect only this operation:

```ruby
class CatsClient < Evil::Client
  # ...
  scope :cats do
    # ...
    operation :fetch do
      option :id

      path { id }
      http_method :get
      response 200
      response(400, 422) { |(status, *)| raise "#{status}: Wrong request" }
      response(404) { raise "404: Not found" }
    end
  end
end
```

Besides operation-specific settings, you can add same definitions for a scope. This definitions are shared by all operations of the scope and its sub-scopes on any level of nesting. Any sub-scope or operation can reload this shared definitions, or update it with those of its own.

```ruby
class CatsClient < Evil::Client
  # ...
  scope :cats do
    path { "cats" } # relative to root scope
    http_method :get
    response 200
    response(400, 422) { |(status, *)| raise "#{status}: Wrong request" }
    response(404) { raise "404: Not found" }

    operation :fetch do
      option :id
      path { id } # relative to upper scope
    end
  end
end
```

The user of custom client sends a request by invoking some operation by name on a corresponding scope.

```ruby
client = CatsClient.new
cats   = client.cats # scope for the `fetch` operation

cats.fetch id: 44 # sends request and returns a processed response
```

Alternatively you can initialize the operation first, and call it later:

```ruby
operation = cats.operations[:fetch].new(id: 44)
operation.call
```

[options]: 
[path]: 
[http method]: 
[security]: 
[headers]: 
[query]: 
[body]: 
[middleware]: 
[connection]: 
[responses]: 
[scope]: 
