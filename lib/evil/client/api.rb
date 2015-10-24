class Evil::Client
  # Container for API settings
  #
  # For now it is only stores the [#base_url].
  #
  #     api = API.new base_url: "127.0.0.1/v1"
  #     api.uri("/users/1/sms") # => "127.0.0.1/v1/users/1/sms"
  #
  # Later it will respond for loading and parsing API settings from a file
  # of specification (swagger etc.)
  #
  # API knows how to convert relative path to URI and provide adapter
  # (connection) to the described server via [#adapter] method.
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

      # @!attribute [w] id_provider
      #
      # @return [#value] Storage for API client ID (to be set from Railtie)
      #
      attr_writer :id_provider

      # API client ID set from Railtie
      #
      # @return [String]
      #
      def default_id
        @id_provider && @id_provider.value
      end
    end

    # @!attribute [r] base
    #
    # @return [String] base url to a RESTful API
    #
    attr_reader :base_url

    # @!attribute [r] request
    #
    # @return [String] request id of the API client
    #
    attr_reader :request_id

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
      @base_url   = settings.fetch(:base_url)
      @request_id = settings.fetch(:request_id) { self.class.default_id }

      validate_base_url
      validate_request_id
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

    def validate_request_id
      fail(RequestIDError) unless request_id
    end
  end
end
