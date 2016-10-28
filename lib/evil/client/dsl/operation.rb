module Evil::Client::DSL
  require_relative "security"
  require_relative "files"

  # Builds a schema for single operation
  class Operation
    attr_reader :schema

    # Builds a schema for a single operation
    #
    # @param  [Object] settings
    # @param  [Proc] block A block of definitions (should accept settings)
    # @return [Hash<Symbol, Object>]
    #
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

    def path
      @schema[:path] = ->(**opts) { yield(opts).gsub(%r{\A/+|/+\z}, "") }
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

    def response(*statuses, raise: false, &block)
      statuses.each do |status|
        @schema[:responses][status] = {
          raise:   raise,
          coercer: block || proc { |response:, **| response }
        }
      end
    end

    # ==========================================================================
    # Utilities for helpers TODO: extract to a separate module
    # ==========================================================================

    def __valid_format__(format)
      formats = %w(json form)
      return format.to_s if formats.include? format.to_s
      fail ArgumentError.new "Invalid format #{format} for body." \
                             " Use one of formats: #{formats}"
    end

    def __model__(model: nil, **, &block)
      if model && block
        Class.new(model, &block)
      elsif block
        Class.new(Evil::Client::Model, &block)
      elsif model
        model
      end
    end
  end
end
