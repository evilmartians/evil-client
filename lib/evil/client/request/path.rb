class Evil::Client::Request
  # Describes the request path as an array of stringified parts without slashes
  #
  # @api public
  #
  class Path < SimpleDelegator
    # Removes trailing slashes from string
    STRIP = %r{[^/].*[^/]|[^/]}.freeze

    # Initializes the path object with a string
    #
    # @param [#to_s] source
    #
    def initialize(source)
      super prepare(Array(source))
    end

    # Adds new parts to the array
    #
    # @param [Array<#to_s>] other
    #
    # @return [Evil::Client::Path]
    #
    def +(other)
      self.class.new super(other)
    end

    # Returns the final string of request path starting from slash
    #
    # @param [String]
    #
    def final
      "/#{join("/")}"
    end

    # Checks the equality of the path to Rails path pattern
    #
    # @param [#to_s] other
    #
    # @return [Boolean]
    #
    def ==(other)
      Mustermann.new(other.to_s, type: :rails) === final
    end

    private

    def prepare(parts)
      parts.flatten.flat_map { |part| part.to_s[STRIP].to_s.split("/") }.compact
    end
  end
end
