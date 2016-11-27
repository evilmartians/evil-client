class Evil::Client
  # Defines a DSL to customize class-level settings of the specific client
  module DSL
    require_relative "dsl/base"
    require_relative "dsl/files"
    require_relative "dsl/http_method"
    require_relative "dsl/path"
    require_relative "dsl/response"
    require_relative "dsl/responses"
    require_relative "dsl/security"
    require_relative "dsl/verifier"
    require_relative "dsl/operation"
    require_relative "dsl/operations"
    require_relative "dsl/scope"

    # Adds [#operations] to a specific client's instances
    def self.extended(klass)
      klass.include Dry::Initializer.define -> { param :operations }
    end

    # Helper to define params and options a for a client's constructor
    #
    # @example
    #   class MyClient < Evil::Client
    #   end
    #
    #   MyClient.new "https://foo.com", user: "bar", token: "baz"
    #
    # @param  [Proc] block
    # @return [self]
    #
    def settings(&block)
      return self unless block
      schema[:settings] = Class.new { include Dry::Initializer.define(&block) }
      self
    end

    # Helper to define base url of the server
    #
    # @param [#to_s] value
    # @return [self]
    #
    def base_url(&block)
      return self unless block
      schema[:base_url] = block
      self
    end

    # Helper specify a connection to be used by a client
    #
    # @param  [#to_sym] type (nil)
    #   The specific type of connection. Uses NetHTTP by default.
    # @return [self]
    #
    def connection(type = nil, &block)
      schema[:connection] = Connection[type]
      schema[:middleware] = Middleware.new(&block)
      self
    end

    # Helper to declare operation, either default or specific
    #
    # @param  [#to_sym] name (nil)
    # @param  [Proc] block
    # @return [self]
    #
    def operation(name = nil, &block)
      schema[:operations].register(name, &block)
      self
    end

    # Helper to define scopes of the client's top-level DSL
    #
    # @param  [#to_sym] name (:[])
    # @param  [Proc] block
    # @return [self]
    #
    def scope(name = :[], &block)
      klass = Class.new(Scope, &block)
      define_method(name) do |*args, **options|
        klass.new(*args, __scope__: self, **options)
      end
      self
    end

    # Takes constructor arguments and builds a final schema for an instance
    # (All the instantiation magics goes here)
    #
    # @param  [Object] *args
    # @return [Hash<Symbol, Object>]
    #
    def new(*args)
      settings   = schema[:settings].new(*args)
      base_url   = schema[:base_url].call(settings)
      middleware = schema[:middleware].finalize(settings)
      operations = schema[:operations].finalize(settings)
      client     = schema[:connection].new URI(base_url)
      connection = Middleware.prepend.(middleware.(Middleware.append.(client)))

      data = operations.each_with_object({}) do |(key, schema), hash|
        hash[key] = Evil::Client::Operation.new schema, connection
      end

      super(data)
    end

    private

    BASE_URL = proc { raise NotImplementedError.new "Base url is not defined" }

    def schema
      @schema ||= {
        settings:   Class.new,
        base_url:   BASE_URL,
        connection: Connection[nil],
        middleware: Middleware.new,
        operations: Operations.new
      }
    end
  end
end
