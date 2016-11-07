# Base structure for models describing parts of requests and responses
#
# The initializer accepts a hash with symbol/string keys,
# from which it takes and validates necessary options.
#
# The method [#to_h] converts nested data to hash
# with symbolic keys at any level of nesting.
#
class Evil::Client
  class Model
    class << self
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

      def attributes
        @attributes ||= []
      end

      def option(name, type = nil, as: nil, **opts)
        super.tap { attributes << (as || name).to_sym }
      end
      alias_method :attribute, :option
      alias_method :param, :option

      private

      def inherited(klass)
        super
        klass.instance_variable_set :@attributes, attributes.dup
      end
    end

    def ==(other)
      other.respond_to?(:to_h) ? to_h == other.to_h : false
    end

    def to_h
      self.class.attributes.each_with_object({}) do |key, hash|
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
