class Evil::Client
  #
  # Resolves body of the request from operation schema for given settings.
  #
  # It uses last (nested) definition without any coercion or validation.
  # Formatting and validation is made later by [Evil::Client::Resolver#__call__]
  # because it depends from both :body and :format definitions.
  #
  # @private
  #
  class Resolver::Body < Resolver
    private

    def initialize(schema, settings)
      super(schema, settings, :body)
    end

    def __call__
      super { instance_exec(&__blocks__.last) if __blocks__.any? }
    end
  end
end
