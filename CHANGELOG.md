# v0.3.1 2016-11-22

## Fixed
- Loading of 'json' from stdlib (nepalez)

## Internal
- Class `Evil::Client::Model` is extracted to `evil-struct` gem (nepalez)

[Compare v0.3.0...v0.3.1](https://github.com/dry-rb/dry-initializer/compare/v0.3.0...v0.3.1)

# v0.3.0 2016-11-18

This version changes the way of processing responses. Instead of dealing
with raw rake responses, we add opinionated methods to gracefully process
responses from JSON or plain text.

In the next minor versions processors for both "form" and "file" (multipart)
formats will be added.

## BREAKING CHANGES
- Method `DSL#response` was redefined with a new signature (nepalez)

  The method takes 2 _mandatory_ positional params: unique name and
  integer status. This allows to process responses with the same status,
  and different structures, like in the following example, where errors
  are returned with the same status 200 (not 4**) as success:

  ```ruby
  operation :update_user do
    # ...
    response :success, 200, model: User
    response :error,   200, model: Error
  end
  ```

  This time response handler will try processing a response using various
  definitions (in order of their declaration) until some suits. The hanlder
  returns `UnexpectedResponseError` in case no definition proves suitable.

  Names (the first param) are unique. When several definitions use the same name,
  only the last one will be applicable.

## Added
- Method `DSL#responses` to share options between response definitions (nepalez)

  ```ruby
  responses format: "json" do
    responses raise: true do
      response :failure,   400
      response :not_found, 404
    end
  end
  ```

  This is the same as:

  ```ruby
  response :failure,   400, format: "json", raise: true
  response :not_found, 404, format: "json", raise: true
  ```
