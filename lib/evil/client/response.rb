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
    # In case of successful response, deserializes the content and
    # converts all hashes to the extended hashes (Hashie::Mash)
    #
    # @return [Object]
    #
    def content
      @content ||= begin
        source = __getobj__.content
        (error? || source.empty?) ? source : Helper.hashify(JSON source)
      end
    end
  end
end
