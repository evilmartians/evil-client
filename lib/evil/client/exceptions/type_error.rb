class Evil::Client
  #
  # Exception to be risen when user defines a scope/operation with a name,
  # that has been used by existing operation/scope.
  #
  class TypeError < ::TypeError
    # Checks whether a name can be used to define operation/scope of the schema
    #
    # @param  [Evil::Client::Schema::Scope] scope
    # @param  [Symbol] name
    # @param  [Symbol] type
    # @return [Symbol] nil
    # @raise  [self] if name cannot be used
    #
    def self.check!(schema, name, type)
      return if type == :scope && schema.operations[name].nil?
      return if type == :operation && schema.scopes[name].nil?

      raise new(name, type)
    end

    private

    def initialize(name, new_type)
      old_type = new_type == :scope ? :operation : :scope
      super "The #{old_type} :#{name} was already defined." \
            " You cannot create #{new_type} with the same name."
    end
  end
end
