Use `let` helper to add virtial memoized attributes to the scope/operation.

```ruby
class CatsAPI < Evil::Client
  option :version, default: proc { 0 }
  option :release, default: proc { 1 }

  let(:full_version) { [version, release].join(".") } # "0.1" by default
end
```

These virtual attributes are available inside all block declarations, including [validations].

[validations]:
