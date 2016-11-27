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
      keys  = REGISTRY.keys
      key   = (name || keys.first).to_sym
      klass = REGISTRY.fetch(key) do
        raise ArgumentError.new "Connection '#{key}' is not registered." \
                                " Use the following keys: #{keys}"
      end

      require_relative "connection/#{key}"
      const_get klass
    end

    # @abstract Sends request to the server and returns rack-compatible response
    def call(_env, *)
      raise NotImplementedError
    end
  end
end
