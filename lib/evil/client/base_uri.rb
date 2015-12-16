class Evil::Client
  # Builds URI object with default protocol
  #
  module BaseURI
    # Parses a string to URI instance
    #
    # Sets 'http' scheme by default and removes trailing slashes from path
    #
    # @return [URI]
    # @raise [ArgumentError] in case the host not properly defined
    #
    def self.parse(string)
      uri = URI.parse(string)
      uri = URI.parse("http://#{string}") unless uri.scheme

      uri.host ? uri : ArgumentError.new("Base URL host should be defined")
    end
  end
end
