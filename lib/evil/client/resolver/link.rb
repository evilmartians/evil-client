class Evil::Client
  #
  # Resolves a link to documentaton for the request
  # from operation settings and schema
  # @private
  #
  class Resolver::Link < Resolver
    private

    def initialize(schema, settings)
      super schema, settings, :link
    end

    def __call__
      super { instance_exec(&__blocks__.last) if __blocks__.any? }
    end
  end
end
