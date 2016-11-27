module Evil::Client::DSL
  class Operation
    attr_reader :schema

    def finalize(settings)
      @mutex.synchronize do
        @schema = @default.dup
        instance_exec(settings, &@block) if @block
        @schema[:middleware]&.finalize(settings)
        @schema
      end
    end

    private

    def initialize(key, block)
      @mutex   = Mutex.new
      @block   = block
      @default = { key: key, responses: {} }
    end

    # ==========================================================================
    # Helper methods that mutate a @schema
    # ==========================================================================

    def documentation(value)
      @schema[:doc] = value
    end

    def http_method(value)
      @schema[:method] = value.to_s.downcase
    end

    def path(value = nil, &block)
      @schema = Path[schema, value, &block]
    end

    def security(&block)
      @schema[:security] = Security.new(&block)
    end

    def files(&block)
      @schema[:files]  = Files.new(&block)
      @schema[:format] = "multipart"
      @schema.delete :body
    end

    def body(format: "json", **options, &block)
      @schema[:body]   = __model__(options, &block)
      @schema[:format] = __valid_format__(format)
      @schema.delete :files
    end

    def headers(**options, &block)
      @schema[:headers] = __model__(options, &block)
    end

    def query(**options, &block)
      @schema[:query] = __model__(options, &block)
    end

    def responses(options = {}, &block)
      Responses.new(self, options, &block)
    end

    def response(name, status, **options, &block)
      @schema[:responses][name] = Response[status, block: block, **options]
    end

    # ==========================================================================
    # Utilities for helpers TODO: extract to a separate module
    # ==========================================================================

    def __valid_format__(format)
      formats = %w(json form)
      return format.to_s if formats.include? format.to_s
      raise ArgumentError.new "Invalid format #{format} for body." \
                              " Use one of formats: #{formats}"
    end

    def __model__(model: nil, **, &block)
      if model && block
        Class.new(model, &block)
      elsif block
        Class.new(Evil::Struct, &block)
      elsif model
        model
      end
    end
  end
end
