Use `http_method` to define it for the current operation.

```ruby
operation :find_cat do
  http_method :get
end
```

As usual, you have access to current settings. This can be useful to make the method dependent from either a version, or other variation of the api.

```ruby
operation :find_cat do |settings|
  http_method settings.version > 2 ? :post : :get
end
```

You can also set a default method for all operations. It can be reloaded later:

```ruby
operation do
  http_method :get
end

operation :find_cat do
  # sends requests via get
end

operation :update_cat do
  http_method :patch
end
```
