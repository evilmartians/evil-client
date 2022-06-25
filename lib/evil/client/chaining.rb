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

    def method_missing(name, *args, **kwargs, &block)
      return super unless respond_to_missing? name

      (operations[name] || scopes[name]).call(*args, **kwargs)
    end
  end
end
