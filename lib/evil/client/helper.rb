require "hashie"

class Evil::Client
  # Collection of utility functions used by the gem
  #
  # @api private
  #
  module Helper
    # Serializes data so that every hash is converted to extended hashie
    #
    # @example
    #   data   = [{ foo: :bar }]
    #   hashie = Helpers.hashify data
    #   hashie.first.foo # => :bar
    #
    # @param [Object] data
    #
    # @return [Object]
    # 
    def self.hashify(data)
      if data.is_a? Hash
        Hashie::Mash.new data
      elsif data.is_a? Array
        data.map(&method(:hashify))
      else
        data
      end
    end
  end
end
