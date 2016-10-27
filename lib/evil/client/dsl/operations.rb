module Evil::Client::DSL
  require_relative "operation"

  # Container for operations definitions
  # Applies settings to definitions and returns a final schema
  class Operations
    # Adds block definition as a named operation
    #
    # @param [#to_sym] key
    # @param [Proc] block
    # @return [self]
    #
    def register(key, &block)
      @schema[key] = Operation.new(key, block)
      self
    end

    # Applies settings to all definitions and returns a final schema
    #
    # @param  [Object] settings
    # @return [Hash<Symbol, Object>]
    #
    def finalize(settings)
      default = @schema[nil].finalize(settings)
      custom  = @schema.select { |key| key }

      custom.each_with_object({}) do |(key, operation), hash|
        custom = operation.finalize(settings)
        hash[key] = default.merge(custom)
        hash[key][:format] ||= "json"
        hash[key][:responses] = default[:responses].merge(custom[:responses])
      end
    end

    private

    def initialize
      @schema = { nil => Operation.new(nil, nil) }
    end
  end
end
