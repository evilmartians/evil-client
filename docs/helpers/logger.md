You can assign a logger to any instance of operation/scope.

As a rule you would do this assignment to the initialized client:

```ruby
client = CatsClient.new(token: "foobar")
log    = StringIO.new
logger = Logger.new log
```

The client will publish debag messages to the log every time it sets instance of scope/operation schema, or initializes them with some options. Requests and responses are logged at the info level.

Later you can check the log:

```ruby
client.cats.fetch id: 83

log.string
# D, [2017-07-30T22:23:50.262734 #23474] DEBUG -- CatsApi.cats: initializing with options {}...
# D, [2017-07-30T22:23:50.263240 #23474] DEBUG -- #<CatsApi.cats:0x000000034d2710 @token="foobar"> initialized
# D, [2017-07-30T22:23:50.262734 #23474] DEBUG -- CatsApi.cats.fetch: initializing with options {"token"=>"foobar", id"=>83}...
# D, [2017-07-30T22:23:50.263240 #23474] DEBUG -- #<CatsApi.cats.fetch:0x000000034d2840 @token="foobar", "id"=83> initialized
# ...
```
