class Evil::Client
  #
  # @abstract
  # Container that carries schema of operation/scope along with its settings
  # and methods to build sub-scope/operation or perform the current operation.
  #
  class Container
    # Loads concrete implementations of the abstract container
    require_relative "container/scope"
    require_relative "container/operation"

    # The schema containing info about sub-scopes and operations of the scope
    # @return [Evil::Client::Container::ScopeDefinition]
    attr_reader :schema

    # The settings current scope is initialized with
    # @return [Evil::Client::Settings]
    attr_reader :settings

    # Options assigned to the [#settings]
    #
    # These are opts given to the [#initializer],
    # processed (via defaults, coercion, renaming) by a constructor of settings.
    #
    # @return [Hash<Symbol, Object>]
    def options
      @options ||= settings.options
    end

    # The human-friendly representation of the scope instance
    #
    # @example
    #   '#<MyClient.scopes[:users] @version=1>'
    #
    # @return [String]
    def to_s
      "#<#{schema} #{options.map { |key, val| "@#{key}=#{val}" }.join(', ')}>"
    end
    alias_method :to_str,  :to_s
    alias_method :inspect, :to_s

    # (Re)sets current logger
    #
    # @param  [Logger, nil] logger
    # @return [Logger, nil]
    #
    def logger=(logger)
      settings.logger = logger
    end

    # Current logger
    #
    # @return [Logger, nil]
    #
    def logger
      settings.logger
    end

    private

    def initialize(schema, logger = nil, **opts)
      @schema   = schema
      @settings = schema.settings.new(logger, opts)
    end
  end
end
