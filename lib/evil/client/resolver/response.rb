class Evil::Client
  #
  # Resolves rack-compatible response from schema for given settings
  # @private
  #
  class Resolver::Response < Resolver
    private

    def initialize(schema, settings, response)
      @__response__ = Array response
      super schema, settings, :responses, @__response__.first.to_i
    end

    def __call__
      super do
        __check_status__
        instance_exec(*@__response__, &__blocks__.last)
      end
    end

    def __check_status__
      return if __blocks__.any?
      raise ResponseError.new(@__schema__, @__settings__, @__response__)
    end
  end
end
