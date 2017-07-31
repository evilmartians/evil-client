Use helpers `body` and `format` to define content of http message, and how it should be formatted.

We support several formats, namely: `:json` (default), `:text`, `:form`, `:yaml`, and `:multipart`.

## Plain Formats

With default `:json` format, the body should be a hash:

```ruby
class CatsAPI < Evil::Client
  format { :json }
  # ...
  scope :cats do
    # ...
    operation :create do
      option :species
      option :name

      body { { species: species, name: name } }
    end
  end
end
```

Before sending to the stack of [middleware], it will be dumped:

```ruby
CatsAPI.cats.create species: "Acinonyx jubatus", name: "Cheetah"
# sends a request with a body: '{"species":"Acinonyx jubatus","name":"Cheetah"}'
# and a header "Content-Type": "application/json"
```

The same content, but formatted as `:yaml` will send another body and header:

```ruby
class CatsAPI < Evil::Client
  format { :yaml }
end

CatsAPI.cats.create species: "Acinonyx jubatus", name: "Cheetah"
# sends a request with a body: "---\n:species: Acinonyx jubatus\n:name: Cheetah\n'
# and a header "Content-Type": "application/yaml"
```

The `:form` format will make body url encoded:

```ruby
class CatsAPI < Evil::Client
  format { :form }
end

CatsAPI.cats.create species: "Acinonyx jubatus", name: "Cheetah"
# sends a request with a body: "species=Acinonyx jubatus&name=Cheetah"
# and a header "Content-Type": "application/x-www-form-urlencoded"
```

The `:text` just stringifies it as is:

```ruby
class CatsAPI < Evil::Client
  format { :text }
end

CatsAPI.cats.create species: "Acinonyx jubatus", name: "Cheetah"
# sends a request with a body: '{:species=>"Acionyx jubatus",:name=>"Cheetah"}'
# and a header "Content-Type": "text/plain"
```

This format doesn't require the body to be hash. It can be anything.

## Multipart Formats

When you need sending files you should select the `:multipart` format. This time the whole body is formatted as `form/multipart`.
Depending on its type (hash, file, StringIO), the content will be formatted correspondingly. Arrays are treated as several parts of the body. All other objects will be stringified.

```ruby
class CatsAPI < Evil::Client
  # ...
  scope :cats do
    # ...
    operation :upload do
      option :files, method(:Array)

      format { :multipart }
      body   { files }
    end
  end
end

CatsAPI.cats.upload files: [StringIO.new("Cheetah"), StrinIO.new("Lion")]
```

[middleware]:
