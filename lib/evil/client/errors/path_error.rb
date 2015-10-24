module Evil::Client::Errors
  # Exception for the case API doesn't support given relative path
  #
  # @api public
  #
  class PathError < RuntimeError
    # Initializes exception for unsupported path
    #
    # @param [#to_s] path
    #
    def initialize(path)
      super "Path '#{path}' cannot be resolved to URI"
    end
  end
end
