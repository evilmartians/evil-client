class Evil::Client
  # @abstract Base class for a specific connection to remote uri
  class Connection
    REGISTRY = { net_http: "NetHTTP" }.freeze

    extend Dry::Initializer::Mixin
    param :base_uri

    # Envokes a specific connection class
    #
    # @param  [#to_sym] key
    # @return [Class]
    #
    def self.[](name = nil)
      key = (name || REGISTRY.keys.first).to_sym

      klass = REGISTRY.fetch(key) do
        fail ArgumentError.new "Connection '#{key}' is not registered." \
                               " Use the following keys: #{REGISTRY.keys}"
      end

      require_relative "connection/#{key}"
      const_get klass
    end

    # @abstract Sends request to the server and returns rack-compatible response
    #
    # @param  [Hash] env
    # @return [Array]
    #
    def call(_env)
      fail NotImplementedError
    end
  end
end
