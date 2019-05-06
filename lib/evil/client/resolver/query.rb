class Evil::Client
  #
  # Resolves query of the request from operation settings and schema
  # by deeply merging queries defined by schema and all its parents.
  #
  # @private
  #
  class Resolver::Query < Resolver
    private

    def initialize(schema, settings)
      super schema, settings, :query
    end

    def __call__
      super do
        Hash __blocks__
          .map { |block| __normalize__ instance_exec(&block) }
          .reduce({}) { |left, right| __deep_merge__(left, right) }
      end
    end

    def __normalize__(data)
      return if data.nil?
      raise __definition_error__("#{data} is not a hash") unless data.is_a? Hash

      __stringify_keys__(data)
    end

    def __deep_merge__(left, right)
      return right unless left.is_a?(Hash) && right.is_a?(Hash)

      left  = __stringify_keys__(left)
      right = __stringify_keys__(right)
      right.each_key { |key| left[key] = __deep_merge__ left[key], right[key] }

      left
    end
  end
end
