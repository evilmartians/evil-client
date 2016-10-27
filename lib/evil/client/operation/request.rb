class Evil::Client::Operation
  # Builds a request env from user options by applying schema validations
  class Request
    extend Dry::Initializer::Mixin
    param :schema

    # Builds an env
    #
    # @param  [IO, nil] file (nil)
    # @param  [Hash<Symbol, Object>] options
    # @return [Hash]
    #
    def build(options)
      {
        format:       schema[:format],
        http_method:  http_method,
        path:         path.call(options),
        security:     schema[:security]&.call(options),
        files:        schema[:files]&.call(options),
        query:        schema[:query]&.new(options).to_h,
        body:         schema[:body]&.new(options).to_h,
        headers:      schema[:headers]&.new(options).to_h
      }
    end

    private

    def key
      @key ||= schema[:key]
    end

    def http_method
      return schema[:method] if schema[:method]
      fail NotImplementedError.new "No method defined for operation '#{key}'"
    end

    def path
      return schema[:path] if schema[:path]
      fail NotImplementedError.new "Path not defined for operation '#{key}'"
    end
  end
end
