class Evil::Client
  #
  # Resolves headers of the request from operation settings and schema
  # by merging headers defined by schema and all its parents.
  # @private
  #
  class Resolver::Headers < Resolver
    private

    def initialize(schema, settings)
      super schema, settings, :headers
    end

    def __call__
      super do
        __blocks__.map { |block| __normalize__ instance_exec(&block) }
                  .reduce({}, :merge)
                  .reject { |_, value| value&.empty? }
      end
    end

    def __normalize__(headers)
      __check__(headers)
      keys   = __extract_keys__(headers)
      values = __extract_values__(headers)
      keys.zip(values).to_h
    end

    def __check__(data)
      raise __definition_error__ "#{data} is not a hash" unless data.is_a? Hash
    end

    def __extract_keys__(data)
      keys = data.keys.map(&:to_s)
      wrong = keys.reject { |key| key[VALID_KEY] }.map(&:inspect)
      return keys unless wrong.any?

      raise __definition_error__ "inacceptable headers #{wrong.join(', ')}"
    end

    def __extract_values__(data)
      data.values.map { |v| v.respond_to?(:map) ? v.map(&:to_s) : v.to_s }
    end

    VALID_KEY = /^.+$/.freeze
  end
end
