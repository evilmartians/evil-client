module Evil::Client::DSL
  SchemaError = Class.new(StandardError)

  # Verifies a final schema
  class Verifier
    def self.call(schema)
      new(schema).call
    end

    def call
      @schema.each do |key, schema|
        check_path(key, schema)
        check_method(key, schema)
      end
    end

    private

    def initialize(schema)
      @schema = schema
    end

    def check_path(key, schema)
      return if schema[:path]
      raise SchemaError,
            "Path definition is missed for operation :#{key}"
    end

    def check_method(key, schema)
      return if schema[:method]
      raise SchemaError,
            "HTTP method definition is missed for operation :#{key}"
    end
  end
end
