When you provide a client to remote API, you would provide some means for its users to test their operations.

Surely, they could use [webmock] to check the ultimate requests that are sent to the server. But doing this, they would inadvertedly specify not their own code, but your client's code too. What do they actually need is a means to check calls of your client's operations. This way they would back on correctness of your client, and take its interface as an endpoint.

For this reason, we support a special RSpec matcher `perform_operation`. It checks, what operations are called via evil-client, and what options are used in there.

The matcher isn't loaded by default, so you must require it first:

```ruby
require "evil/client/rspec"
```

Providing that you defined some client...

```ruby
class CatsClient < Evil::Client
  option :token
  # ...
  scope :cats do
    option :version
    # ...
    operation :fetch do
      option :id
      # ...
    end
  end
end
```

... lets write a specification:

```ruby
require "evil/client/rspec"

RSpec.describe CatsClient, "cats.fetch" do
  let(:client) { CatsClient.new(token: "foo") }
  let(:scope)  { client.cats(version: 1) }

  it "fetches a cat by id" do
    expect { scope.fetch(id: 8) }
      .to perform_operation("CatsClient.client.fetch")
  end
end
```

You can add chaining using one of 3 additional methods: `with`, `with_exactly`, or `without`.

## with

This method checks that the operation **includes some options**:

```ruby
expect { scope.fetch(id: 8) }
  .to perform_operation("CatsClient.client.fetch")
  .with token: "foo"
```

## with_exactly

This time you can check the full list of options given to operation:

```ruby
expect { scope.fetch(id: 8) }
  .to perform_operation("CatsClient.client.fetch")
  .with_exactly token: "foo", version: 1, id: 8
```

## without

You can also check that some keys are absent:

```ruby
expect { scope.fetch(id: 8) }
  .to perform_operation("CatsClient.client.fetch")
  .without :name, :email
```

This can be useful to check a behaviour of the client with optional attributes.

All checks can be negated as well:

```ruby
expect { scope.fetch(id: 8) }
  .not_to perform_operation("CatsClient.client.fetch")
  .with token: "foo"
```

**Notice**: Under the hood the matcher doesn't stub the request, so its better to stub all requests by hand:

```ruby
require "webmock/rspec"

before { stub_request :any, // }
```

[webmock]: https://github.com/bblimke/webmock