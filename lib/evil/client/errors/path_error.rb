module Evil::Client::Errors
  # Exception for the case API doesn't support given relative path
  class PathError < RuntimeError
    # Initializes exception for unsupported path
    #
    # @param [#to_s]
    #
    def initialize(path)
      super "Path '#{path}' cannot be resolved to URI"
    end
  end
end
