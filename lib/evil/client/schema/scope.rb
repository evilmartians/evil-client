require_relative "operation"

class Evil::Client
  #
  # Mutable container of definitions for sub-scopes and operations
  # with DSL to configure those definitions.
  #
  class Schema::Scope < Schema::Operation
    # Tells that this is a schema for a scope (not the final operation)
    #
    # @return [false]
    #
    def leaf?
      false
    end

    # The collection of named sub-scope schemas
    #
    # Every sub-scope schema refers to the current one as a [#parent]
    #
    # @return [Hash<Symbol, Class>]
    #
    def scopes(*_args)
      @__children__.reject { |_, child| child.leaf? }
    end

    # The collection of named operation schemas
    #
    # @return [Hash<[Symbol, nil], Class>]
    #
    def operations(*_args)
      @__children__.select { |_, child| child.leaf? }
    end

    # Creates or updates sub-scope definition
    #
    # @param  [#to_sym] name The unique name of subscope inside current scope
    # @param  [Proc] block The block containing definition for the subscope
    # @return [self]
    #
    def scope(name, **_kwargs, &block)
      key = NameError.check!(name)
      TypeError.check! self, key, :scope
      @__children__[key] ||= self.class.new(self, key)
      @__children__[key].instance_exec(&block)
      self
    end

    # Creates or updates operation definition
    #
    # @param  [#to_sym] name The unique name of operation inside the scope
    # @param  [Proc] block The block containing definition for the operation
    # @return [self]
    #
    def operation(name, &block)
      key = NameError.check!(name)
      TypeError.check! self, key, :operation
      @__children__[key] ||= self.class.superclass.new(self, key)
      @__children__[key].instance_exec(&block)
      self
    end

    private

    def initialize(*)
      super
      @__children__ = {}
    end
  end
end
