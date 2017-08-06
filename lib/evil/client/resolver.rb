class Evil::Client
  #
  # @abstract
  # Base class for resolvers of schema definition for a particular settings.
  #
  # Its every subclass responds for resolving a specific part of schema
  # (request, middleware or response).
  #
  class Resolver
    # Loads concrete implementation of the abstract resolver
    require_relative "resolver/request"
    require_relative "resolver/middleware"
    require_relative "resolver/response"

    # Builds and calls one-off resolver at once
    #
    # @param  [Object] args The arguments of current class' constructor
    # @return [Object] resolved definition
    #
    def self.call(*args)
      new(*args).send(:__call__)
    end

    # Human-friendly representation of the resolver
    #
    # @return [String]
    #
    def to_s
      "#{@__keys__.join(' ')} from #{@__schema__} for #{@__settings__}"
    end
    alias_method :to_str,  :to_s
    alias_method :inspect, :to_s

    private

    def initialize(schema, settings, *keys)
      @__schema__   = schema
      @__settings__ = settings
      @__keys__     = keys
    end

    def __call__
      logger = @__settings__.logger
      yield.tap do |obj|
        logger&.debug(self.class) { "resolved #{self} to #{obj.inspect}" }
      end
    rescue => err
      logger&.error(self.class) { "failed to resolve #{self}: #{err.message}" }
      raise
    end

    def __blocks__
      @__blocks__ ||= [].tap do |blocks|
        schema = @__schema__
        loop do
          break unless schema
          block  = schema.definitions.dig(*@__keys__)
          schema = schema.parent
          blocks.unshift block if block
        end
      end
    end

    def __definition_error__(text)
      DefinitionError.new(@__schema__, @__keys__, @__settings__, text)
    end

    def __symbolize_keys__(hash)
      hash.each_with_object({}) { |(key, val), obj| obj[key.to_sym] = val }
    end

    def __stringify_keys__(hash)
      hash.each_with_object({}) { |(key, val), obj| obj[key.to_s] = val }
    end

    def respond_to_missing?(name, *)
      @__settings__.respond_to? name
    end

    def method_missing(*args, &block)
      respond_to_missing?(*args) ? @__settings__.send(*args, &block) : super
    end
  end
end
