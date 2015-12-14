class Evil::Client::Request
  # Parses base_url string to host, port and relative path
  #
  class BaseURL
    # Initializes the object from source string
    #
    # @param [String] source
    #
    def initialize(source)
      @uri = parse(source)
    end

    # The port extracted from source
    #
    # @return [Integer]
    #
    def port
      @port ||= @uri.port
    end

    # The protocol of the request
    #
    # @return [String]
    #
    def protocol
      @protocol ||= @uri.scheme
    end

    # The host with protocol extracted from source
    #
    # @return [String]
    #
    def host
      @host ||= @uri.host[STRIP_SLASHES]
    end

    # The list of path's parts extracted from the source
    #
    # @return [Array<String>]
    #
    def path
      @path ||= "/#{@uri.path[STRIP_SLASHES]}"
    end

    private

    def parse(base_url)
      path, port = base_url.to_s.split(%r{\:(\d+)$})

      uri = URI.parse path
      uri = URI.parse "http://#{path}" unless uri.scheme
      uri.port = port.to_i if port
      return uri if uri.host

      fail "base_url should be set"
    end
  end
end
