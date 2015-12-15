class Evil::Client
  module RSpec
    # Stubs strictly defined requests with a current response
    #
    # @example Block syntax
    #   # Stubs 'POST /foo/1?bar=BAZ' with body 'baz=QUX'
    #   # to return 200 with json { bar: :BAZ, baz: :QUX }
    #   #
    #   allow_request { client.path(:foo, 1).query(bar: :BAZ) }
    #     .to_respond_with(200, bar: :BAZ, baz: QUX)
    #
    # @example Argument syntax
    #   allow_request(client.path(:foo, 1).query(bar: :BAZ))
    #     .to_respond_with(200, bar: :BAZ, baz: QUX)
    #
    # @param [Evil::Client, nil] client
    #
    # @return [Evil::Client::Stub]
    #
    def allow_request(client = nil)
      Stub.new(self, client || yield, true)
    end

    # Stubs partially defined requests with a current response
    #
    # @example Block syntax
    #   # Stubs 'POST /foo/1?bar=BAZ' with any body including 'baz=QUX'
    #   # to return 200 with json { bar: :BAZ, baz: :QUX }
    #   #
    #   allow_any_request { client.path(:foo, 1).query(bar: :BAZ) }
    #     .to_respond_with(200, bar: :BAZ, baz: QUX)
    #
    # @example Argument syntax
    #   allow_any_request(client.path(:foo, 1).query(bar: :BAZ))
    #     .to_respond_with(200, bar: :BAZ, baz: QUX)
    #
    # @param [Evil::Client, nil] client
    #
    # @return [Evil::Client::Stub]
    #
    def allow_any_request(client = nil)
      Stub.new(self, client || yield, false)
    end

    # Hash of stubs defined for various client adapters
    #
    # { client => strict => { request => response } }
    #
    # @return [Hash<Evil::Client::Adapter, Hash>]
    #
    # @api private
    #
    def evil_client_stubs_registry
      @evil_client_stubs_registry ||= Hash.new(true => {}, false => {})
    end

    # Adds new stub to the registry and re-stubs the adapter
    #
    # @param [Evil::Client::Adapter]  adapter
    # @param [Evil::Client::Request]  request
    # @param [Evil::Client::Response] response
    # @param [Boolean] strict
    #
    # @return [undefined]
    #
    # @api private
    #
    def register_evil_client_stub(adapter, request, response, strict)
      evil_client_stubs_registry[adapter][strict][request] = response
      apply_evil_client_stub(adapter)
    end

    # Stubs the adapter using all definitions: { request => response }
    #
    # @param [Hash<Evil::Client::Request, Evil::Client::Response>] adapter
    #
    # @return [undefined]
    #
    # @api private
    #
    def apply_evil_client_stub(adapter)
      stubs    = evil_client_stubs_registry[adapter]
      stricts  = stubs[true]
      partials = stubs[false]

      allow(adapter).to receive(:send_request) do |actual|
        stub = stricts.find { |req, _| actual == req } ||
          partials.find { |req, _| actual.include? req } ||
          fail(StubError.new actual)
        
        stub.last
      end
    end

    # Prepares a stub
    #
    # @api private
    #
    class Stub
      # Initializes stub of request
      #
      # By default sets the response to [200, {}]
      #
      # @param [Object] context The context of the RSpec example
      # @param [Evil::Client] client
      #
      def initialize(context, client, strict = true)
        @context = context
        @client  = client
        @strict  = strict
      end

      # Whether the request should be stabbed strictly (via equality),
      # or partially (via equivalence)
      #
      # @return [Boolean]
      #
      attr_reader :strict

      # The request to be stabbed
      #
      # @return [Evil::Client::Request]
      #
      def request
        @request ||= @client.current_request
      end

      # The client's adapter to be stabbed
      #
      # @return [Evil::Client::Adapter]
      #
      def adapter
        @adapter ||= @client.adapter
      end

      # Stubs the request
      #
      # @param [#to_i]     status The http status of the response
      # @param [Hash, nil] body   The response body represented as a hash
      #
      # @return [Evil::Client::Stub]
      #
      def to_respond_with(status, body = nil)
        raw_body = body.nil? ? nil : JSON.generate(body)
        response = Response.new(status, raw_body)
        @context.register_evil_client_stub(adapter, request, response, strict)
      end
    end

    # The error to be raised when unknown request is sent
    #
    class StubError < RuntimeError
      # Initializes the error for the unexpected request
      #
      # @param [Evil::Client::Request] request
      #
      def initialize(request)
        super <<-MESSAGE.gsub(/ +\|/, "")
          |Unexpected request has been sent by http client:
          |  #{request.method.upcase} #{request.protocol}://#{request.host}:#{request.port}#{request.path}
          |  with headers: #{request.headers}
          |  with body:    #{request.body}
          |  with query:   #{request.query}
        MESSAGE
      end
    end
  end
end
