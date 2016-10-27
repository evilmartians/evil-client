module Evil::Client::DSL
  # Provides a namespace for client's top-level DSL
  class Scope
    extend Dry::Initializer::Mixin
    option :__scope__, default: proc {}

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

    private :__scope__

    def respond_to_missing?(name, *)
      __scope__.respond_to? name
    end

    def method_missing(name, *args)
      super unless respond_to? name
      __scope__.send(name, *args)
    end
  end
end
