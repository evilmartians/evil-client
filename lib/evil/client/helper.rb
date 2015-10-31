require "hashie"

class Evil::Client
  # Collection of utility functions used by the gem
  #
  # @api private
  #
  module Helper
    # Deserializes a JSON string to the nested structure of arrays and hashies
    #
    # @param [String] string
    #
    # @return [Object]
    # 
    def self.deserialize(string)
      data = JSON string rescue nil
      hashify(data)
    end

    # Serializes data so that every hash is converted to extended hashie
    #
    # @example
    #   data   = [{ foo: { bar: [baz: { foo: :qux }] } }]
    #   hashie = Helpers.hashify data
    #   hashie.foo.bar[:baz].foo # => :qux
    #
    # @param [Object] data
    #
    # @return [Object]
    # 
    def self.hashify(data)
      if data.is_a? Hash
        Hashie::Mash.new data.keys.zip(hashify data.values).to_h
      elsif data.is_a? Array
        data.map(&method(:hashify))
      else
        data
      end
    end
  end
end
