module Evil::Client::DSL
  # Provides a namespace for client's top-level DSL
  class Scope
    extend Dry::Initializer::Mixin
    option :__scope__, default: proc {}, reader: :private

    # Declares a method that opens new scope inside the current one
    # An instance of new scope has access to methods of its parent
    #
    # @param  [#to_sym] name (:[]) The name of the new scope
    # @return [self]
    #
    def self.scope(name = :[], &block)
      klass = Class.new(Scope, &block)
      define_method(name) do |*args, **options|
        klass.new(*args, __scope__: self, **options)
      end
      self
    end

    private

    def method_missing(name, *args)
      __scope__.send(name, *args)
    end
  end
end
