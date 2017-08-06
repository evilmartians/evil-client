class Evil::Client
  #
  # Exception to be risen when schema definitions cannot be resolved.
  # This is possibly a bug in client definition.
  #
  class DefinitionError < StandardError
    private

    def initialize(schema, keys, settings, text)
      super "failed to resolve #{keys.join(' ')} from #{schema} schema" \
            " for #{settings}: #{text}. Possibly this means a lack of" \
            " necessary validations in definition of the client."
    end
  end
end
