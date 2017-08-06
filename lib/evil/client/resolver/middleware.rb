class Evil::Client
  #
  # Resolves scope/operation-specific middleware from schema for some settings
  #
  # New middleware are added to previously defined ones.
  # To reset all predefined middleware, set value to nil.
  #
  # @private
  #
  class Resolver::Middleware < Resolver
    private

    def initialize(schema, settings)
      super schema, settings, :middleware
    end

    def __call__
      super do
        __blocks__.map.with_object([]) do |block, obj|
          list = __normalize__ instance_exec(&block)
          obj.replace([]) unless list
          obj.concat Array(list)
        end.reverse
      end
    end

    def __normalize__(value)
      case value
      when nil   then nil
      when Class then value
      when Array then value.flatten.compact.map { |val| __normalize__(val) }
      else raise __definition_error__("#{value} is neither class nor array")
      end
    end
  end
end
