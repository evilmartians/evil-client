class Evil::Client
  module RSpec
    # Stubs the client with a current response
    #
    # @example Block syntax
    #   # Stubs 'POST /foo/1?bar=BAZ' with body 'baz=QUX'
    #   # to return 200 with json { bar: :BAZ, baz: :QUX }
    #   #
    #   allow_client { client.path(:foo, 1).query(bar: :BAZ) }
    #     .to_request(:post, baz: :QUX)
    #     .with_response(200, bar: :BAZ, baz: QUX)
    #
    # @example Argument syntax
    #   allow_client(client.path(:foo, 1).query(bar: :BAZ))
    #     .to_request(:post, baz: :QUX)
    #     .with_response(200, bar: :BAZ, baz: QUX)
    #
    # @param [Evil::Client, nil] client
    #
    # @return [Evil::Client::Stub]
    #
    def allow_client(client = nil)
      Stub.new(self, client || yield)
    end

    # Hash of stubs defined for various client adapters
    #
    # { client => { request => response } }
    #
    # @return [Hash<Evil::Client::Adapter, Hash>]
    #
    # @api private
    #
    def evil_client_stubs_registry
      @evil_client_stubs_registry ||= Hash.new({})
    end

    # Adds new stub to the registry and re-stubs the adapter
    #
    # @param [Evil::Client::Adapter]  adapter
    # @param [Evil::Client::Request]  request
    # @param [Evil::Client::Response] response
    #
    # @return [undefined]
    #
    # @api private
    #
    def register_evil_client_stub(adapter, request, response)
      evil_client_stubs_registry[adapter][request] = response
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
      stubs = evil_client_stubs_registry[adapter]
      allow(adapter).to receive(:send_request) do |actual|
        response = stubs.select { |req, _| actual.include? req }.values.first
        response || fail(StubError.new actual)
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
      def initialize(context, client)
        @context = context
        @client  = client
      end

      # @!attribute [r] context
      #
      # @return [Object] The context of the RSpec example
      #
      attr_reader :context

      # @!attribute [r] context
      #
      # @return [Object] The stubbed client
      #
      attr_reader :client

      # @!attribute [r] request
      #
      # @return [Evil::Client::Request] The request to be stabbed
      #
      attr_reader :request

      # The client's adapter to be stabbed
      #
      # @return [Evil::Client::Adapter]
      #
      def adapter
        @adapter ||= client.adapter
      end

      # Defines the request to be stubbed
      #
      # @param [#to_s] type The type of the request
      # @param [Hash]  data Either a query (GET) or a body of the request
      #
      # @return [self] itself
      #
      def to_request(type, data = {})
        @request = client.prepare_request(type, data)
        self
      end

      # Stubs the request
      #
      # @param [#to_i]     status The http status of the response
      # @param [Hash, nil] body   The response body represented as a hash
      #
      # @return [Evil::Client::Stub]
      #
      def and_respond(status, body = nil)
        raw_body = body.nil? ? nil : JSON.generate(body)
        response = Response.new(status, raw_body)
        context.register_evil_client_stub(adapter, request, response)
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
          |  #{request.type.upcase} #{request.path}
          |  with headers: #{request.headers}
          |  with body:    #{request.body}
          |  with query:   #{request.query}
        MESSAGE
      end
    end
  end
end
