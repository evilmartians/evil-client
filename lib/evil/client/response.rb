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
    # @return [Hashie::Mash, Array<Hashie::Mash>] in case of non-empty response
    # @return [nil] in case of empty response
    #
    def content
      @content ||= Hashie::Mash.new handle_error(extract_content)
    end

    # Numeric status of the http response
    #
    # @return [Integer]
    #
    def status
      code.to_i
    end

    private

    def extract_content
      (!body && success?) ? {} : JSON.parse(body)
    rescue => error
      raise error unless error? # only error is allowed to be non-JSON
      { error: body }
    end

    def handle_error(hash)
      return hash unless error?

      hash[:error] ||= true
      hash.update(meta: { http_code: status })
    end
  end
end
