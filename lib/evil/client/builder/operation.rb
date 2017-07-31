class Evil::Client
  #
  # Lazy container for a [#schema] and [#parent] settings
  # of a [#new] operation to be initialized with its own options,
  # that reload the [#parent] ones.
  #
  class Builder::Operation < Builder
    # Human-readable representation of the handler
    #
    # @example
    #   '#<MyClient.scopes[:users] @version="1.1">.operations[:fetch]'
    #
    # @return [String]
    #
    def to_s
      "#{parent}.operations[:#{schema.name}]"
    end

    # @!method new(options)
    # Builds new operation with options reloading those of its [#parent]
    #
    # @param  [Hash<Symbol, Object>] options ({}) Custom options
    # @return [Evil::Client::Container::Operation]
    #
    def new(**options)
      Container::Operation.new schema, parent.options.merge(options)
    end

    # @!method call(options)
    # Builds and calls operation at once
    #
    # @param  (see #new)
    # @return (see Container::Operation#call)
    #
    def call(**options)
      new(**options).call
    end
    alias_method :[], :call
  end
end
