Evil client supports stack of rack-compatible middleware which is specific for every scope and operation.

As usual, every middleware is just an object wrapped around some application. It should:

- initialize with the only parameter `app` for the rest of stack, wrapped around connection,
- define the only instance method `#call` which takes a [rack environment], and returns a [rack response].

The example of valid middleware which adds the tag "FOO" to the request header:

```ruby
class Foo
  def call(env)
    env["HTTP_Variables"]["Tag"] = "FOO"
    @app.call env
  end

  private

  def initialize(app)
    @app = app
  end
end
```

Use the `middleware` helper method to add a specific class to a stack. You can do this at any level of nesting:

```ruby
class CatsAPI < Evil::Client
  # ...
  middleware Foo

  scope :cats do
    option :version, proc(&:to_i)
    # ...
    middleware { version < 2 ? Bar : [Bar, Baz] }

    operation :fetch do
      middleware { Qux }
      # ...
    end
  end
end

# Depending on version, this will send rack request to either
# [Foo, Bar, Qux, Evil::Client::Connection]      (versions 1-)
# [Foo, Bar, Baz, Qux, Evil::Client::Connection] (versions 2+)
#
# The response will be processed in the reverse order
```

You can place the same class to the stack several times.

The order of definitions is important. The request is processed by middleware in the order from root to operation, and the response will be processed in reverse order -- from operation to the root.

[rack environment]: http://www.rubydoc.info/github/rack/rack/file/SPEC#The_Environment
[rack response]: http://www.rubydoc.info/github/rack/rack/file/SPEC#The_Response