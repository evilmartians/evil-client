require "net/http"
require "net/https"

class Evil::Client
  class Connection
    # Net::HTTP based implementation of [Evil::Client::Connection]
    class NetHTTP < Connection
      # Sends a request to the remote uri,
      # and returns rack-compatible response
      #
      # @param  [Hash] env Middleware environment with keys:
      #   :http_method, :path, :query_string, :body_string, :headers
      # @return [Array] Rack-compatible response [status, body, headers]
      #
      def call(env, *)
        request = build_request(env)
        Net::HTTP.start base_uri.host, base_uri.port, opts do |http|
          handle http.request(request)
        end
      end

      private

      def opts
        @opts ||= {}.tap { |hash| hash[:use_ssl] = base_uri.scheme == "https" }
      end

      def build_request(env)
        type, path, query, body, headers = parse_env(env)

        sender = build_sender(type)
        uri    = build_uri(path, query)

        sender.new(uri).tap do |request|
          request.body = body
          headers.each { |key, value| request[key] = value }
        end
      end

      def parse_env(env)
        env.values_at :http_method, :path, :query_string, :body_string, :headers
      end

      def build_sender(type)
        Net::HTTP.const_get type.capitalize
      end

      def build_uri(path, query)
        base_uri.merge(URI.encode(path)).tap { |uri| uri.query = query }
      end

      def handle(response)
        [response.code.to_i, Hash(response.header), Array(response.body)]
      end
    end
  end
end
