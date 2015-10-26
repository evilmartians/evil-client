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

    # @api private
    class << self
      # @!attribute [rw] logger
      #
      # @return [Object] Shared logger for all api-specific http connections
      #
      attr_accessor :logger
    end

    # @!attribute [r] base
    #
    # @return [String] base url to a RESTful API
    #
    attr_reader :base_url

    # @!method initialize(settings)
    # Initializes API specification with given settings
    #
    # @param [Hash] settings
    # @option settings [String] :base_url
    #   The base url of the API with required protocol and path
    # @option settings [String] :request_id
    #   The API client request id
    #   If Rails is available it is set authomatically from [#default_id],
    #   otherwise it should be assigned explicitly
    #
    # @raise [Evil::Client::Errors::URLError] in case of invalid path
    #
    def initialize(settings)
      @base_url = settings.fetch(:base_url)
      validate_base_url
    end

    # API-specific adapter (connection to remote server)
    #
    # @return [JSONclient]
    #
    def adapter
      @adapter ||= begin
        http_client = JSONClient.new(base_url: base_url)
        http_client.debug_dev = self.class.logger
        http_client
      end
    end

    # Prepares a full URI from given relative path
    #
    # @param [String] path
    #
    # @return [String]
    #
    def uri(path)
      URI.join("#{base_url}/", path).to_s
    end

    private

    def validate_base_url
      fail(URLError, base_url) unless URI(base_url).host
    end
  end
end
