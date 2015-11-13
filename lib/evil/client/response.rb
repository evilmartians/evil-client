class Evil::Client
  # Describes a server response
  #
  # @api public
  #
  class Response < SimpleDelegator
    # Checks whether a server responded with a success
    #
    # @return [Boolean]
    #
    def success?
      status < 400
    end

    # Checks whether a server responded with error
    #
    # @return [Boolean]
    #
    def error?
      !success?
    end

    # The content of the response
    #
    # @return [String] in case of error response
    # @return [nil] in case of empty response
    # @return [Hashie::Mash, Array<Hashie::Mash>] in case of non-empty response
    #
    def content
      @content ||= begin
        source = __getobj__.content
        if error?
          source
        elsif source.empty?
          nil
        else
          Helper.hashify(JSON source)
        end
      end
    end
  end
end
