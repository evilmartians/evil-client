class Evil::Client
  #
  # Support chaining of calls for nested scopes/operations
  #
  module Chaining
    Names.clean(self) # Remove unnecessary methods from the instance

    private

    def respond_to_missing?(name, *)
      operations[name] || scopes[name]
    end

    def method_missing(name, *args, &block)
      return super unless respond_to_missing? name

      (operations[name] || scopes[name]).call(*args)
    end
  end
end
