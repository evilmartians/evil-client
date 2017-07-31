class Evil::Client
  #
  # Resolves a link to documentaton for the request
  # from operation settings and schema
  # @private
  #
  class Resolver::HttpMethod < Resolver
    private

    def initialize(schema, settings)
      super schema, settings, :http_method
    end

    def __call__
      super do
        value = instance_exec(&__blocks__.last)&.to_s&.upcase if __blocks__.any?
        raise __not_defined_error__    if value.to_s == ""
        raise __invalid_error__(value) unless LIST.include? value
        value
      end
    end

    def __not_defined_error__
      __definition_error__ "HTTP method not defined"
    end

    def __invalid_error__(value)
      __definition_error__ "Unknown HTTP method #{value}"
    end

    # @see https://tools.ietf.org/html/rfc7231#section-4
    # @see https://tools.ietf.org/html/rfc5789#section-2
    LIST = %w[GET POST PUT PATCH DELETE OPTIONS HEAD TRACE CONNECT].freeze
  end
end
