# Base structure for models describing parts of requests and responses
#
# The initializer accepts a hash with symbol/string keys,
# from which it takes and validates necessary options.
#
# The method [#to_h] converts nested data to hash
# with symbolic keys at any level of nesting.
#
# FIXME: extract this structure to the separate gem
#
class Evil::Client
  class Model
    class << self
      class Attributes
        def self.call(*args, &block)
          new(*args).instance_eval(&block)
        end

        def initialize(klass, **options)
          @klass   = klass
          @options = options
        end

        def attribute(name, **options)
          @klass.send :attribute, name, @options.merge(options)
        end
        alias_method :option, :attribute
        alias_method :param,  :attribute
      end

      include Dry::Initializer::Mixin

      def new(value)
        return value if value.is_a? self
        value = value.to_h.each_with_object({}) do |(key, val), obj|
          obj[key.to_sym] = val
        end
        super value
      end
      alias_method :call, :new
      alias_method :[], :new

      def attributes(**options, &block)
        Attributes.call(self, **options, &block)
      end

      def list_of_attributes
        @list_of_attributes ||= []
      end

      def option(name, type = nil, as: nil, **opts)
        super.tap { list_of_attributes << (as || name).to_sym }
      end
      alias_method :attribute, :option
      alias_method :param, :option

      private

      def inherited(klass)
        super
        klass.instance_variable_set :@list_of_attributes, list_of_attributes.dup
      end
    end

    def ==(other)
      other.respond_to?(:to_h) ? to_h == other.to_h : false
    end

    def to_h
      self.class.list_of_attributes.each_with_object({}) do |key, hash|
        val = send(key)
        hash[key] = hashify(val) unless val == Dry::Initializer::UNDEFINED
      end
    end
    alias_method :[], :send

    private

    def hashify(value)
      if value.is_a? Evil::Client::Model
        value.to_h
      elsif value.respond_to? :to_hash
        value.to_hash
             .each_with_object({}) { |(key, val), obj| obj[key] = hashify(val) }
      elsif value.is_a? Enumerable
        value.map { |val| hashify(val) }
      else
        value
      end
    end
  end
end
