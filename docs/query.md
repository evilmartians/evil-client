Use `query` to add some data to the request query. The syntax is pretty the same as for [body][body] and [headers][headers].

```ruby
operation :find_cat do |settings|
  # ...
  path { "cats" }
  query do
    attribute :token, default: proc { settings.token }
    attribute :id
  end
end

# Later at the runtime it will send a request to "../cats?id=4&token=foo"
client.operations[:find_cat].call id: 4, token: "foo"
```

## Nested Data Representation

Nested data are represented in a query following Rails convention:

```ruby
client.operations[:find_cat].call id: [{ key: 4 }], token: ["foo"]
# "/cats?id[][key]=4&token[]=foo"
```

Non-unicode symbols are encoded as defined in [RFC-3986][rfc-3986]

## Model-Based Queries

Use [models][model] to provide validation of query data:

```ruby
class Cat < Evil::Struct
  attribute :name,  type: Dry::Types["strict.string"], optional: true
  attribute :age,   type: Dry::Types["strict.int"],    default:  proc { 0 }
  attribute :color, type: Dry::Types["strict.string"]
end
```

You can either restrict `type` of an attribute:

```ruby
operation :create_cat do
  query do
    attribute :cat, type: Cat
  end
end

# Later at runtime will send "...?cat[color]=tabby&cat[age]=0"
client.operations[:create_cat].call cat: { color: "tabby" }
```

...or use in for the query as a whole under the `model` key:

```ruby
operation :create_cat do
  query model: Cat
end

# Later at runtime will send "...?color=tabby&age=0"
client.operations[:create_cat].call color: "tabby"
```

In the last case you can define additional attributes (this redefinition is local, it don't affect a model by itself):

```ruby
operation :create_cat do
  query model: Cat do
    attribute :mood, default: proc { "sleeping" }
  end
end

# Later at runtime will send "...?color=tabby&age=0&mood=sleeping"
client.operations[:create_cat].call color: "tabby"
```

**Be careful!** You cannot reload existing attributes (this will cause an exception). 

In operations that update remote data you can skip some attributes (mark them `optional`). If you need to check responses strictly (to require all the necessary attributes), you should provide different models.

```ruby
# Requires remote server to return consistent beasts
class Cat
  attribute :id,   type: Dry::Types["strict.int"].constrained(gt: 0)
  attribute :age,  type: Dry::Types["strict.int"]
  attribute :name, type: Dry::Types["strict.string"]
end

# Allows updating attributes when necessary
class CatUpdate
  attribute :age,  type: Dry::Types["coercible.int"],    optional: true
  attribute :name, type: Dry::Types["coercible.string"], optional: true
end
```

[rfc-3986]: https://tools.ietf.org/html/rfc3986
[body]:
[headers]:
[model]:
