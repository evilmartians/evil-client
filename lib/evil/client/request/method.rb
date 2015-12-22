class Evil::Client::Request
  # Describes a method of the request, that is case- and string/symbol agnostic
  #
  class Method < String
    # Initializes an object from string or symbol
    #
    # @param [#to_s] value
    #
    def initialize(value)
      super prepare(value)
    end

    # Checks equality of the method to another object
    #
    # @param [#to_s] other
    #
    # @return [Boolean]
    #
    def ==(other)
      super prepare(other)
    end

    private

    def prepare(value)
      value.to_s.upcase
    end
  end
end
