class Evil::Client
  #
  # Contains schema and settings of some scope along with methods
  # to initialize its sub-[#scopes] and [#operations]
  #
  class Container::Scope < Container
    include Chaining

    # The collection of named sub-scope constructors
    # @return [Hash<Symbol, Evil::Client::Container::Scope::Builder>]
    def scopes
      @scopes ||= schema.scopes.transform_values do |sub_schema|
        Builder::Scope.new(sub_schema, settings)
      end
    end

    # The collection of named operations constructors
    # @return [Hash<Symbol, Evil::Client::Container::Operation::Builder>]
    def operations
      @operations ||= \
        schema.operations.each_with_object({}) do |(key, sub_schema), obj|
          next unless key

          obj[key] = Builder::Operation.new(sub_schema, settings)
        end
    end
  end
end
