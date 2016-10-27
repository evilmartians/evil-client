Models are simple nested structures, based on [dry-initializer][dry-initializer] and [dry-types][dry-types].

They are needed to prepare and validate nested bodies and queries, as well as wrap and validate responses.

# Model Definition

To define a model create a subclass of `Evil::Client::Model` and define its attributes.

```ruby
class Cat < Evil::Client::Model
  attribute :name,  type: Dry::Types["strict.string"], optional: true
  attribute :age,   type: Dry::Types["coercible.int"], default: proc { 0 }
  attribute :color, type: Dry::Types["strict.string"]
end
```

The method `attribute` is just an alias of [dry-initializer `option`][dry-initializer]. Because model's constructor takes options only, not params, `param` is reloaded as another alias of `option`. You can use any method you like.

To initialize an instance send a hash of options to the constructor:

```ruby
cat = Cat.new(name: "Navuxodonosor II", age: "15", color: "black")
cat.name  # => "Navuxodonosor II"
cat.age   # => 15
cat.color # => "black"
```

You can build a model from another one (it just returns the object back):

```ruby
Cat.new Cat.new(name: "Navuxodonosor II", age: 15, color: "black")
```

or from a hash with string keys:

```ruby
Cat.new("name" => "Navuxodonosor II", "age" => 15, "color" => "black")
```

You can use other (nested) models in type definitions:

```ruby
class CatPack < Evil::Client::Model
  attribute :cats, type: Dry::Types["array"].member(Cat)
end

CatPack.new cats: [{ name: "Navuxodonosor II", age: 15, color: "black" }]
```

Models can be converted back to hashes with **symbolic** keys:

```ruby
cat = Cat.new(name: "Navuxodonosor II", age: "15", color: "black")
cat.to_h # => { name: "Navuxodonosor II", age: "15", color: "black" }
```

The model ignores all options it doesn't know about, and applies constraints to known ones only.

```ruby
# Cats don't care about your expectations
cat = Cat.new(name: "Navuxodonosor II", age: "15", color: "black", expectation: "hunting")
cat.to_h # => { name: "Navuxodonosor II", age: "15", color: "black" }
```

If all you need is data filtering, just use a shortcut `.[]`:

```ruby
Cat[name: "Navuxodonosor II", age: "15", color: "black", expectation: "hunting"]
# => { name: "Navuxodonosor II", age: "15", color: "black" }
```

# Model Usage

You can use models in definitions of request [body][body], [query][query], and [headers][headers]...

```ruby
operation :create_cat do
  method :post
  path { "cats" }
  body model: Cat
end
```

...and in [response][response] processing:

```ruby
operation :create_cat do
  # ...
  response 201 do |body:, **|
    Cat[JSON.parse(body)]
  end
end
```

# Distinction of Models from Dry::Struct

Models are like ~~onions~~ structures, defined in [`dry-struct`][dry-struct]. Both models and structures support hash arguments, type constraints, nested data, and backward hashification via `to_h`. You can check [dry-struct documentation] to make an impression of how it works.

Nethertheless, there is an important difference between the implementations of nested structures.

## Undefined Values vs nils

The main reason to define gem-specific model is the following. In `Dry::Struct` both the `optional` and `default` properties belong to value type constraint. The gem does not draw the line between attributes that are not set, and those that are set to `nil`.

To the contrary, in [dry-initializer][dry-initializer] and `Evil::Client::Model` both `optional` and `default` properties describe not a value type by itself, but its relation to the model. An attribute value can be set to `nil`, or been kept in undefined state.

Let's see the difference on the example of `StructCat` and `ModelCat`:

```ruby
class StructCat < Dry::Struct
  attribute :name, type: Dry::Types["strict.string"].optional
  attribute :age,  type: Dry::Types["coercible.int"].default(0)
end

class ModelCat < Evil::Client::Model
  attribute :name, type: Dry::Types["strict.string"], optional: true
  attribute :age,  type: Dry::Types["coercible.int"], default: proc { 0 }
end

struct_cat = StructCat.new
struct_cat.name # => nil
struct_cat.age  # => 0
struct_cat.to_h # => { name: nil, age: 0 }

model_cat = ModelCat.new
model_cat.name # => #<Dry::Initializer::UNDEFINED>
model_cat.age  # => 0
model_cat.to_h # => { age: 0 }

model_cat = ModelCat.new name: nil
model_cat.name # => nil
model_cat.age  # => 0
model_cat.to_h # => { name: nil, age: 0 }
```

Notice that in a model hashification ignores undefined attributes. This is important to filter arguments of a request. In PUT/PATCH requests (update server-side data) there is a difference between values not changed, and those that are explicitly reset to `nil`.

## Tolerance to Unknown Options

A model's constructor ignores unknown options, so you can safely sent any ones:

```ruby
# Oh, no, this is a cat, not a bat!
model_cat = ModelCat.new name: "Abraham", flying_distance: "5 miles"

# so we simply ignore flying_distance
model_cat.to_h # => { name: "Abraham", age: 0 }
```

This behaviour allows us to slice only necessary arguments for [body][body], [query][query], and [headers][headers] of a request.

## Stringified Keys in Constructor

Ahother difference between structs and models is that models can take hashes with both symbolic and string keys.

This addition is useful when processing [responses][response]:

```ruby
# This works even though JSON#parse returns a hash with string keys
ModelCat.new JSON.parse('{"age":4}')
```

## Equality

Models, whose methods `to_h` returns equal hashes, are counted as equal.

[dry-initializer]: http://dry-rb.org/gems/dry-initializer
[dry-struct]: http://dry-rb.org/gems/dry-struct
[dry-types]: http://dry-rb.org/gems/dry-types
[body]:
[headers]:
[query]:
[response]:
