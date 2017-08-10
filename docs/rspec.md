When you provide a client to remote API, you would provide some means for its users to test their operations.

Surely, they could use [webmock] to check the ultimate requests that are sent to the server. But doing this, they would inadvertedly specify not their own code, but your client's code too. What do they actually need is a means to stub and check invocations of your client's operations. This way they would back on correctness of your client, and take its interface as an endpoint.

For this reason, we support a special RSpec stubs and expectations. sThey are not loaded by default, so you must require it first, and then include the module:

```ruby
require "evil/client/rspec"

RSpec.describe CatsClient, "cats.fetch" do
  include Evil::Client::RSpec
  # ...
end
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
    stub_client_operation(CatsClient, "cats.fetch")
      .with(token: "foo", version: 1, id: 8) # full hash of collected options
      .to_return 8 # returned value by operation

    expect(scope.fetch(id: 8)).to eq 8
    expect_client_operation(CatsClient, "cats.fetch")
      .to_have_been_performed
  end
end
```

## Selection

To select stubbed operations you can specify client class:

```ruby
stub_client_operation(CatsClient)
```

or its superclass

```ruby
stub_client_operation(Evil::Client)
```

or leave it for default `Evil::Client`:

```ruby
stub_client_operation()
```

or add a fully qualified name of the operation (for **exact** matching):

```ruby
stub_client_operation(CatsClient, "cats.fetch")
```

or regexp for partial matching:

```ruby
stub_client_operation(CatsClient, /fetch/)
```

or use method `with` to check options exactly:

```ruby
stub_client_operation(CatsClient, "cats.fetch").with(token: "foo", version: 1, id: 8)
```

or partially:

```ruby
stub_client_operation(CatsClient, "cats.fetch").with(hash_including(id: 8))
```

or via block:

```ruby
stub_client_operation(CatsClient, "cats.fetch").with { |opts| opts[:id] == 8 }
```

## Return value

You **must** define some value returned by a stub:

```ruby
stub_client_operation(CatsClient, "cats.fetch").to_return(8)
```

or fall back to original implementation:

```ruby
stub_client_operation(CatsClient, "cats.fetch").to_call_original
```

or raise an exception:

```ruby
stub_client_operation(CatsClient, "cats.fetch").to_raise StandardError, "Wrong id"
```

## Some Hint

[webmock]: https://github.com/bblimke/webmock