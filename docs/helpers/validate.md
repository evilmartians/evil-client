Use `validate` helper to check interconnection between several options.

It takes a block, where all options are available. You should call method
`errors.add :some_key, **some_options` or `errors.add "some message"`
to invalidate options.

```ruby
class CatsAPI < Evil::Client
  option :token,    optional: true
  option :user,     optional: true
  option :password, optional: true

  # All requests should be made with either token or user/password
  # This is required by any request
  validate { errors.add :wrong_credentials unless token.nil? ^ password.nil? }
  validate { errors.add :missed_password   unless user.nil? ^ !password }

  scope :cats do
    option :version, proc(&:to_i)

    # Check that operation of cats scope include token after API v1
    # This doesn't affect other subscopes of CatsAPI root scope
    validate { errors.add :missed_token unless token || version.zero? }
  end

  # ...
end

CatsAPI.new password: "foo" # raises Evil::Client::ValidationError
```

The error message is translated using i18n gem in **english** locale.
You don't need to add `:en` to `I18n.available_locales`, we make it
under the hood and then restore previous settings.

All you need is to provide translations for a corresponding scope which is
`en.evil.client.errors.{class_name}.{scopes and operations}` as shown below.

```yaml
# config/locales/evil-client.en.yml
---
en:
  evil:
    client:
      errors:
        cats_api:
          wrong_credentials: "Provide either a token or a password"
          missed_password:   "User and password should accompany one another"
          cats:
            missed_token: "The token is required for operations with cats in API v1+"
```

Alternatively you can call `errors.add "some message"` without any translation. Only symbolic keys are translated via i18n, while string messages used in exceptions as is. This time you don't need adding translation at all.

Remember, that you can initialize client with some valid options, and then reload that options in a nested subscope/operation. All validations defined from the root of the client will be used for any set of options. For example:

```ruby
client = CatsAPI.new token: "foo"
# valid

cats = client.cats(version: 0)
# valid

cats.fetch id: 3
# valid

cats.fetch id: 3, token: nil
# fails due to wrong credentials

cats.fetch id: 3, token: nil, user: "andy", password: "qux"
# valid

cats.fetch id: 3, token: nil, user: "andy", password: "qux", version: 1
# fails due to missed token
```
