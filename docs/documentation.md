Use the `documentation` to provide reference to online docs for the current operation.

```ruby
operation :find_cat do |settings| # remember that you have access to settings
  documentation "https://cats.example.com/v#{settings.version}/docs/find_cats"
end
```

The link will be shown in exceptions risen when either request or response mismatches type constraints.
