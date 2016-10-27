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
      alias_method :attribute, :option
      alias_method :param, :option

      def new(value)
        return value if value.is_a? self
        value = value.to_h.each_with_object({}) do |(key, val), obj|
          obj[key.to_sym] = val
        end
        super value
      end

      def call(value)
        new(value).to_h
      end
      alias_method :[], :call
    end

    tolerant_to_unknown_options

    def ==(other)
      return false unless other.respond_to? :to_h
      to_h == other.to_h
    end

    def to_h
      attributes = method(:initialize)
                   .parameters
                   .map { |item| item[1] unless item[0] == :keyrest }
                   .compact

      attributes.each_with_object({}) do |key, hash|
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
