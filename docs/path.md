Use `path` to define operation's path that is relative to the [base url][base_url].

```ruby
operation :find_cats do
  path { "cats" }
end
```

Notice that a value should be wrapped into the block. This is necessary to build paths dependent on arguments of the request. The following definition inserts a mandatory id from options:

```ruby
operation :find_cat do
  path { |id:, **| "cats/#{id}" }
end

# later at a runtime
client.operations[:find_cat].call id: 98 # sends to "/cats/98"
```

As usual, you have access to current settings. This can be useful to add client tokens to paths when necessary:

```ruby
operation :find_cats do |settings|
  path { "cats/#{settings.token}" }
end
```

## Default Path

You can set a default path for all operations. Use it to DRY clients whose operations differs not by endpoints, but, for example, by parameters ([query][query], [body][body]) of various requests:

```ruby
operation do
  path { "cats" }
end

operation :find_cats do
  # sends requests to "/cats"
end

operation :find_details do
  path { "cats/details" } # reloads default setting
end
```

[base_url]:
[query]:
[body]:
