require "hashie/mash"

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
      @content ||= begin
        hash = extract_content
        hash.update(meta: { http_code: __getobj__.status }) if error?
        Hashie::Mash.new hash
      end
    end

    private

    def extract_content
      source = __getobj__.content
      (source.empty? && success?) ? {} : JSON(source)
    rescue => error
      raise error unless error? # only error is allowed to be non-JSON
      { error: source }
    end
  end
end
