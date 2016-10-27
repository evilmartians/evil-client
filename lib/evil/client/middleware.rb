class Evil::Client
  # Builds and carries stack of middleware parameterized by settings
  #
  # @example
  #   # during client definition
  #   middleware = Evil::Client::Middleware.new do |settings|
  #     run CustomMiddleware if settings.version > 1
  #   end
  #
  #   # during client instantiation
  #   stack = middleware.finalize(settings)
  #   conn  = stack.wrap(connection)
  #
  #   # during runtime to make a request
  #   conn.call request
  #
  class Middleware
    class << self
      require_relative "middleware/base"
      require_relative "middleware/merge_security"
      require_relative "middleware/normalize_headers"
      require_relative "middleware/stringify_json"
      require_relative "middleware/stringify_multipart"
      require_relative "middleware/stringify_query"
      require_relative "middleware/stringify_form"

      # Middleware to be added on top of full stack (before custom ones)
      def prepend
        new do
          run NormalizeHeaders
          run MergeSecurity
        end.finalize
      end

      # Middleware to be added on bottom of full stack
      # (between custom stack and connection)
      def append
        new do
          run StringifyQuery
          run StringifyJson
          run StringifyForm
          run StringifyMultipart
        end.finalize
      end
    end

    # Applies client settings to build stack of middleware
    #
    # @param  [Object] settings
    # @return [self]
    #
    def finalize(settings = nil)
      @mutex.synchronize do
        @stack = []
        instance_exec(settings, &@block) if @block
        self
      end
    end

    # Wraps the connection instance to the current stack of middleware
    #
    # @param  [#call] connection
    # @return [#call]
    #
    def call(other)
      @stack.reverse.inject(other) { |a, e| e.new(a) }
    end

    private

    def initialize(&block)
      @mutex = Mutex.new
      @block = block
    end

    def run(klass)
      @stack << klass
      self
    end
  end
end
