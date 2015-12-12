class Evil::Client
  # Describes a server response
  #
  # @api public
  #
  class Response < SimpleDelegator
    # @!attribute [r] status
    #
    # @return [Integer] status of the response
    #
    attr_reader :status

    # @!attribute [r] body
    #
    # @return [String] raw body of the response
    #
    attr_reader :body

    # Initializes the response with status and body
    #
    # @param [#to_i]  status The status of the response
    # @param [String] body   The raw body of the response
    #
    def initialize(status, body)
      @status = status.to_i
      @body   = body
    end

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
