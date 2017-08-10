class Evil::Client
  #
  # @abstract
  # Base class for scope/operation builders
  #
  # Every builder just wraps scope/operation schema along with
  # preinitialized [#parent] settings of its super-scope.
  # The instance method [#new] quacks like the lazy constructor
  # for scope/operation instance whose options reload the [#parent]'s ones.
  #
  class Builder
    Names.clean(self) # Remove unnecessary methods from the instance

    # Load concrete implementations for the abstact builder
    require_relative "builder/scope"
    require_relative "builder/operation"

    # The schema for an instance to be constructed via [#new]
    # @return [Evil::Client::Schema]
    attr_reader :schema

    # The instance of parent scope carrying default settings
    # @return [Evil::Client::Container::Scope]
    attr_reader :parent

    # Alias method for [#to_s]
    #
    # @return [String]
    #
    def to_str
      to_s
    end

    # Alias method for [#to_s]
    #
    # @return [String]
    #
    def inspect
      to_s
    end

    private

    def initialize(schema, parent)
      @schema = schema
      @parent = parent
    end
  end
end
