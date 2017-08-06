class Evil::Client
  #
  # Resolves request format from operation settings and schema
  # @private
  #
  class Resolver::Format < Resolver
    private

    def initialize(schema, settings)
      super schema, settings, :format
    end

    def __call__
      super do
        value = instance_exec(&__blocks__.last)&.to_sym if __blocks__.any?
        value = :json if value.to_s == ""
        raise __invalid_error__(value) unless LIST.include? value
        value
      end
    end

    def __invalid_error__(value)
      __definition_error__ "Format :#{value} not supported." \
                           " Use one of the following formats:" \
                           " :#{LIST.join(', :')}."
    end

    LIST = %i[json yaml form text multipart].freeze
  end
end
