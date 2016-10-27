class Evil::Client
  # Defines a DSL to customize class-level settings of the specific client
  module DSL
    require_relative "dsl/operations"
    require_relative "dsl/scope"

    # Stack of default middleware before custom midleware and a connection
    # This stack cannot be modified
    DEFAULT_MIDDLEWARE = Middleware.new do
      run Middleware::MergeSecurity
      run Middleware::StringifyJson
      run Middleware::StringifyQuery
      run Middleware::NormalizeHeaders
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

    # Takes constructor arguments and builds a final schema for the instance
    #
    # @param  [Object] *args
    # @return [Hash<Symbol, Object>]
    #
    def finalize(*args)
      settings   = schema[:settings].new(*args)
      uri        = URI(schema[:base_url].call(settings))
      client     = schema[:connection].new(uri)
      middleware = schema[:middleware].finalize(settings)
      stack = Middleware.prepend.(middleware.(Middleware.append.(client)))

      { connection: stack, operations: schema[:operations].finalize(settings) }
    end

    private

    BASE_URL = -> (_) { fail NotImplementedError.new "Base url not defined" }

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
