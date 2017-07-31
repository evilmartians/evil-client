class Evil::Client
  #
  # Lazy container for a [#schema] and [#parent] settings
  # of a [#new] scope to be initialized with its own options,
  # that reload the [#parent] ones.
  #
  class Builder::Scope < Builder
    # Human-readable representation of the handler
    #
    # @example
    #   '#<MyClient.scopes[:crm] @version="1.1">.scopes[:users]'
    #
    # @return [String]
    #
    def to_s
      "#{parent}.scopes[:#{schema.name}]"
    end

    # @!method new(options)
    # Builds new scope with options reloading those of its [#parent]
    #
    # @param  [Hash<Symbol, Object>] options Custom options
    # @return [Evil::Client::Container::Scope]
    #
    def new(**options)
      Container::Scope.new schema, parent.options.merge(options)
    end
    alias_method :call, :new
    alias_method :[],   :new
  end
end
