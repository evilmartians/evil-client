Use `validate` helper to check interconnection between several options.

The helper takes name (unique for a current scope) and a block. Validation fails when a block returns falsey value.

```ruby
class CatsAPI < Evil::Client
  option :token,    optional: true
  option :user,     optional: true
  option :password, optional: true

  # All requests should be made with either token or user/password
  # This is required by any request
  validate(:valid_credentials) { token ^ password }
  validate(:password_given)    { user ^ !password }

  scope :cats do
    option :version, proc(&:to_i)

    # Check that operation of cats scope include token after API v1
    # This doesn't affect other subscopes of CatsAPI root scope
    validate(:token_based) { token || version.zero? }
  end

  # ...
end

CatsAPI.new password: "foo" # raises Evil::Client::ValidationError
```

The error message is translated using i18n gem. You should provide translations for a corresponding scope:

```yaml
# config/locales/evil-client.en.yml
---
en:
  evil:
    client:
      errors:
        cats_api:
          valid_credentials: "Provide either a token or a password"
          password_given:    "User and password should accompany one another"
          cats:
            token_based: "The token is required for operations with cats in API v1+"
```

The root scope for error messages is `{locale}.evil.client.errors.{class_name}` as shown above.

Remember, that you can initialize client with some valid options, and then reload that options in a nested subscope/operation. All validations defined from the root of the client will be used for any set of options. See the example:

```ruby
client = CatsAPI.new token: "foo"
# valid

cats = client.cats(version: 0)
# valid

cats.fetch id: 3
# valid

cats.fetch id: 3, token: nil
# fails due to 'valid_credentials' is broken

cats.fetch id: 3, token: nil, user: "andy", password: "qux"
# valid

cats.fetch id: 3, token: nil, user: "andy", password: "qux", version: 1
# fails due to 'cats.token_based' is broken
```
