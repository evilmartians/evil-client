# Change Log
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog], and this project adheres
to [Semantic Versioning].

## [1.1.0] To be released ASAP

Some syntax sugar has been added to both the client and its RSpec helpers.

### Added

- Assigned options are wrapped into simple delegator with rails-like methods
  `#slice` and `#except`. This helps when you need to select part of assigned
  options for some part of a request (nepalez)

  Remember the options are collected from the very root of the client,
  so at the endpoint operation there could be a lot of options
  related to other endpoints, or to a different part of the request.

- Every container has reference to its `#client` along the standalone `#name`
  of its schema. This allows to select operation containers by
  `#client`, `#name`, `#options` to stub their methods `#call` (nepalez)

- RSpec stubs and expectations for operations (nepalez, palkan)

### Removed

- RSpec matcher `perform_operation` has been dropped in favor of
  `stub_client_operation` and `expect_client_operation` (nepalez)

- Unnecessary instance methods inherited from [Object] are removed
  from various classes to avoid name conflicts with user-provided
  scopes and operations (nepalez)

## [1.0.0] [2017-08-06]

This is a total new reincarnation of the gem. I've changed its
architecture for consistency and unification reasons. This version is
backward-incompatible to all the previous ones up to the [0.3.3].

Its DSL was re-written and regularized as well. While the idea of the gem
remains about the same as before, its implementation has been changed
drastically in many important details.

### [BREAKING] Changed

- There is no more differencies between "root" DSL, DSL of scope and
  operation. All scopes use exactly the same methods. All operations
  uses just the same methods except for `#operation` and `#scope` that
  provide further nesting.

  Any customization (inside a sub-scope or operation of some scope)
  re-loads previous definitions in the following order:

  ```text
  root operation(anonymous)
    subscope operation(anonymous)
      # ...
        custom(named) operation
  ```

- Unlike previous versions every named operation belongs to some scope
  (possibly nested into parents ones). Operations/subscopes should
  have unique names inside its scope only (no more global namespace
  for all operations).

  Every scope knows the list of its subscopes and operations like:

  ```ruby
  MyClient.new.scopes[:users].operations[:fetch]
  ```

- You can describe operations step-by-step. For example, you have
  to describe `path` of root anonymous operation. Later you can add subpath
  in the corresponding operation or scope:

  ```ruby
  class MyClient
    option :subdomain
    path { "https://#{subdomain}.foobar.com" } # same as base_path

    scope :users do
      option :version

      # makes full path "https://{subdomain}.foobar.com/v{version}/users"
      path { "v#{version}/users" }

      operation :fetch do
        option :id

        # the final path: "https://{subdomain}.foobar.com/v{version}/users/{id}"
        path { id }
      end
    end
  end
  ```

- As a syntax sugar all undefined methods are delegated to subscopes
  and operations.

  Instead of full syntax:

  ```ruby
  MyClient.new
          .scopes[:users][version: "1.1"]
          .operations[:fetch][id: 7]
          .call
  ```

  You can use more natural one:

  ```ruby
  MyClient.new.users(version: "1.1").fetch(id: 7)
  ```

- Every scope or operation takes some options.
  Defined options are inherited and collected from the very root of the client:

  ```ruby
  client = MyClient.new token: "foo", bar: :baz
  client.options # => { token: "foo" }

  users = client.users(version: 3)
  users.options # => { token: "foo", version: 3 }

  fetch = users.operations[:fetch][id: 7]
  fetch.options # => { token: "foo", version: 3, id: 7 }
  ```

- You can reload assigned options at any level of nesting

  ```ruby
  users.options # => { token: "foo", version: 3 }
  
  fetch = users.operations[:fetch][id: 7, token: "baz"]
  fetch.options # => { token: "baz", version: 3, id: 7 }
  ```

- When adding an option you can define the necessary coercers, default values
  and requirements using the [dry-initializer] gem API.

  ```ruby
  class MyClient
    option :token,     proc(&:to_s)  # required
    option :subdomain, proc(&:to_s), default: { "europe" }
  end
  ```

- In addition you can define validator to check whether options
  correspond to each other:

  ```ruby
  class MyClient
    option :token,    optional: true
    option :password, optional: true

    validate(:valid_credentials) { token.nil? ^ password.nil? }
  end
  ```

  You have to add i18n localization for that errors:

  ```yaml
  # config/locales/evil-client.en.yml
  en:
    evil:
      client:
        errors:
          my_client:
            valid_credentials: "You should set either token or password"
  ```

  All validations from root will be applied at every single instance
  (of subscope or operation). Every time we validate current (reloaded) options.

- The method `let` allows to define custom memoizers:

  ```ruby
  class MyClient
    option :first_name, proc(&:to_s)
    option :last_name,  proc(&:to_s)

    let(:full_name) { [first_name, last_name].join(" ") }
  end
  ```

  Such memoizers are available in validators and request/response declarations.

- Definitions of request/response parts can be made ether as a plain values

  ```ruby
  class MyClient
    path "https://api.example.com"
  end
  ```

  or via blocks:

  ```ruby
  class MyClient
    option :subdomain

    path { "https://#{subdomain}.example.com" }
  end
  ```

  Inside the block you can access all the current options.

- Some upper-level operation definitions (path, query, and headers)
  are updated by nested definitions, while the others (http_method, format,
  security settings, request body, and response handler) will be reloaded.

  For example, you can define some shared headers at the client (root) level,
  then add some scope/operation-specific headers later. Or you can define
  security schema by default, and reload it for a specific operation.

- I found customization of underlying client an overkill. That's why
  all clients will be based on the same old Net::HTTP(S) connection.

  But the client connection is just the object with the only required method
  `#call` taking rack-compatible env, and returning rack-compatible response.

  You can define your own connection for a client:

  ```ruby
  my_connection = double call: [200, {}, []]

  class MyClient
    connection = my_connection
  end
  ```

- You can define a middleware for every single operation -- exactly
  in the same way as other parts of operation specification.

  All middleware will be used in the order of their definition:

  ```ruby
  class MyClient
    middleware Foo

    scope :users do
      middleware { [Bar, Baz] }
    end
  end
  ```

  In the above example rack env will be sent to Foo -> Bar -> Baz -> Connection,
  and rack response will be processed by Connection -> Baz -> Bar -> Foo.

- I've simplified some definitions in the OperationDSL.

  Now you should define `headers` and `query` as a simple hashes (no helpers).
  That hashes will be merged to upper-level ones (that's how we customize them).

  You can also define body as either hash, or IO (for files), depending
  on request format.

  You have to define a format for operation via special `format` helper
  (:json by default, :form, :text, :multipart are available as well):

  ```
  operation :upload do
    option :multipart, default: proc { File.new "Hi!" }

    format { :files } # :json (default), :text, and :form are supported as well
    body   { [StringIO.new, "Hi!"] }
  end
  ```

  Because `format` takes a block, you can customize its value depending
  on any option(s).

- Response handlers take a block with rack request: [status, headers, [body]]

  There is no dsl for processing that responses (because it can be anything).
  You don't need to provide models (but you can do it on your own), or
  validate responses in any special way. Do your best!

- No more dependencies from both the `dry-types` and `evil-struct`.

## [0.3.3] - [2017-07-14]

### Fixed
- dependency from 'securerandom' standard library (nepalez)

### Added
- variables for client settings and base_url (nepalez)

# [0.3.2] - [2016-11-29]

### Fixed
- Query and body encoding (nepalez)

### Internal
- Refactoring of some DSL classes (nepalez)

## [0.3.1] - [2016-11-22]

### Fixed
- Loading of 'json' from stdlib (nepalez)

### Internal
- Class `Evil::Client::Model` is extracted to `evil-struct` gem (nepalez)

## [0.3.0] - [2016-11-18]

This version changes the way of processing responses. Instead of dealing
with raw rake responses, we add opinionated methods to gracefully process
responses from JSON or form text.

In the next minor versions processors for both "form" and "file" (multipart)
formats will be added.

### Changed
- [BREAKING] Method `DSL#response` was redefined with a new signature (nepalez)

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
  returns `ResponseError` in case no definition proves suitable.

  Names (the first param) are unique. When several definitions use the same name,
  only the last one will be applicable.

### Added
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

[1.1.0]: https://github.com/evilmartians/evil-client/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/evilmartians/evil-client/compare/v0.3.3...v1.0.0
[0.3.3]: https://github.com/evilmartians/evil-client/compare/v0.3.2...v0.3.3
[0.3.2]: https://github.com/evilmartians/evil-client/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/evilmartians/evil-client/compare/v0.3.0...v0.3.1
[Keep a Changelog]: http://keepachangelog.com/
[Semantic Versioning]: http://semver.org/
[dry-initializer]: http://github.com/dry-rb/dry-initalizer
