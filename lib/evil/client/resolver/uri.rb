class Evil::Client
  #
  # Resolves request URI from operation settings and schema
  # @private
  #
  class Resolver::Uri < Resolver
    private

    def initialize(schema, settings)
      super schema, settings, :path
    end

    def __call__
      super do
        parts = __blocks__.map { |block| instance_exec(&block)&.to_s }
        path  = File.join(parts)
        __uri__(path).tap { |uri| __check__(uri) }
      end
    end

    def __uri__(path)
      URI path
    rescue StandardError => e
      raise __definition_error__(e.message)
    end

    def __check__(uri)
      scheme = uri.scheme
      details = "base url should be defined" unless scheme
      details ||= "base url should use HTTP(S). '#{scheme}' used instead"

      raise __definition_error__(details) unless scheme&.match(/^https?$/)
    end
  end
end
