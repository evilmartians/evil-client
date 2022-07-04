class Evil::Client
  #
  # Mutable container of operation definitions
  # with DSL to configure both settings and parts of request/response.
  #
  class Schema::Operation < Schema
    # Tells that this is a schema for end route (operation)
    #
    # @return [true]
    #
    def leaf?
      true
    end

    # Definitions for the current operation
    #
    # @return [Hash<Symbol, [Proc, Hash<Integer, Proc>]>]
    #
    def definitions
      @definitions ||= { responses: {} }
    end

    # Adds path definition to the schema
    #
    # Root path should be a valid URL for HTTP(S) protocol
    #
    # @param  [#to_s, nil] value
    # @param  [Proc] block
    # @return [self]
    #
    def path(value = nil, &block)
      __define__(:path, value, block)
    end

    # Adds http method definition to the schema
    #
    # @see https://tools.ietf.org/html/rfc7231#section-4
    # @see https://tools.ietf.org/html/rfc5789#section-2
    #
    # @param  [#to_s, nil] value Acceptable http_method
    # @param  [Proc] block
    # @return [self]
    #
    def http_method(value = nil, &block)
      __define__(:http_method, value, block)
    end

    # Adds format for request body
    #
    # @param  [:json, :form, :text, :multipart, nil] value (:json)
    # @param  [Proc] block
    # @return [self]
    #
    def format(value = nil, &block)
      __define__(:format, value, block)
    end

    # Adds security definition to the schema
    #
    # The definition should be nested hash with a root keys :headers, or :query.
    #
    # @example
    #   security { { headers: { "idempotent-token" => "foobar" } } }
    #
    # Inside the block we provide several helpers for standard authentication
    # schemas, namely `basic_auth`, `token_auth`, and `key_auth`. Those are
    # preferred ways to define a security schema:
    #
    # @example
    #   security { token_auth token, prefix: "Bearer" }
    #
    # @param  [Hash<[:headers, :query], Hash>, nil]
    # @param  [Proc] block
    # @return [self]
    #
    def security(value = nil, &block)
      __define__(:security, value, block)
    end

    # Adds request headers definition to the schema
    #
    # Headers should be hash of header-value pairs.
    # Values should be either stringified values or array of stringified values.
    #
    # Nested definition will be merged to the root one(s),
    # so that you can add headers step-by-step from root of the client
    # to its scopes and operations.
    #
    # To reset previous settings you can either set all headers to `nil`,
    # or assign nil to custom headers. All headers with empty values
    # will be ignored.
    #
    # @param  [Hash<#to_s, [#to_s, Array<#to_s>]>, nil] value
    # @param  [Proc] block
    # @return [self]
    #
    def headers(value = nil, &block)
      __define__(:headers, value, block)
    end

    # Adds query definition to the schema
    #
    # Query should be a nested hash.
    # Wnen subscope or operation reloads previously defined query,
    # new definition are merged deeply to older one. You can populate
    # a query step-by-step from client root to an operation.
    #
    # @param  [Hash, nil] value
    # @param  [Proc] block
    # @return [self]
    #
    def query(value = nil, &block)
      __define__(:query, value, block)
    end

    # Adds body definition to the schema
    #
    # It is expected the body to correspond to [#format].
    #
    # When a format is :json,      the body should be convertable to json
    # When a format is :text,      the body should be stringified
    # When a format is :form,      the body should be a hash
    # When a format is :multipart, the body can be object or array of objects
    #
    # Unlike queries, previous body definitions aren't inherited.
    # The body defined for root scope can be fully reloaded
    # at subscope/operation level without any merging.
    #
    # @param  [Object] value
    # @param  [Proc] block
    # @return [self]
    #
    def body(value = nil, &block)
      __define__(:body, value, block)
    end

    # Adds list of middleware to the schema
    #
    # New middleware are added to previously defined (by root).
    # This means the operation-specific middleware will handle the request
    # after a root-specific one, and will handle the response before
    # a roog-specific middleware.
    #
    # Values should be either a Rack middleware class, or array of
    # Rack middleware classes.
    #
    # @param  [Rack::Middleware, <Array<Rack::Middleware>>] value
    # @param  [Proc] block
    # @return [self]
    #
    def middleware(value = nil, &block)
      __define__(:middleware, value, block)
    end

    # Adds response handler definition to the schema
    #
    # @param  [Integer, Array<Integer>] codes List of response codes
    # @param  [Proc] block
    # @return [self]
    #
    def response(*codes, **_kwargs, &block)
      codes.flatten.map(&:to_i).each do |code|
        definitions[:responses][code] = block || proc { |*response| response }
      end
      self
    end
    alias_method :responses, :response

    private

    # @private Method to add definitions to the schema
    def __define__(key, value, block)
      definitions[key] = block || proc { value }
      self
    end
  end
end
