class Evil::Client
  # Container for API settings
  #
  # For now it is only stores the [#base_url].
  #
  #     api = API.new base_url: "127.0.0.1/v1"
  #     api.uri("/users/1/sms") # => "127.0.0.1/v1/users/1/sms"
  #
  # Eventually it will respond for loading and parsing API settings from a file
  # of specification (swagger etc.), validation of requests and responses.
  #
  # @api private
  #
  class API
    include Errors

    # @!attribute [r] base
    #
    # @return [String] base url to a RESTful API
    #
    attr_reader :base_url

    # @!method initialize(settings)
    # Initializes API specification with given settings
    #
    # @param [Hash] settings
    #
    # @raise [Evil::Client::Errors::URLError] in case of invalid path
    #
    def initialize(**settings)
      @settings = settings
    end

    # Base URI with default settings applied
    #
    # @return [URI]
    #
    def base_uri
      @base_uri ||= begin
        source = @settings[:base_url].to_s
        uri = URI.parse source
        uri = URI.parse "http://#{source}" unless uri.scheme
        uri = URI.parse "#{uri}//localhost" unless uri.host
        uri.port = @settings[:port] if @settings[:port]
        uri
      end
    end

    # Base url
    #
    # @return [String]
    #
    def base_url
      @base_url ||= base_uri
    end

    # Prepares a full URI from given relative path
    #
    # @param [#to_s] path
    #
    # @return [String]
    #
    def uri(path)
      path.to_s.empty? ? base_url : URI.join("#{base_url}/", path).to_s
    end
  end
end
