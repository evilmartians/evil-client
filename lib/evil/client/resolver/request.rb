class Evil::Client
  #
  # Resolves request schema for given settings to the minimal Rack environment
  #
  # @return [Hash<String, Object>]
  # @private
  #
  class Resolver::Request < Resolver
    require_relative "uri"
    require_relative "http_method"
    require_relative "security"
    require_relative "headers"
    require_relative "query"
    require_relative "body"
    require_relative "format"

    private

    def initialize(schema, settings)
      super schema, settings, :request
    end

    def __call__
      super { environment }
    end

    # rubocop: disable Metrics/MethodLength
    # rubocop: disable Metrics/AbcSize
    def environment
      {
        "REQUEST_METHOD" => http_method,
        "PATH_INFO" => uri.path,
        "SCRIPT_NAME" => "",
        "QUERY_STRING" => Formatter.call(query, :form),
        "SERVER_NAME" => uri.host,
        "SERVER_PORT" => uri.port,
        "HTTP_Variables" => headers,
        "rack.release" => Rack.release,
        "rack.url_scheme" => uri.scheme,
        "rack.input" => Formatter.call(body, format, boundary: boundary),
        "rack.multithread" => false,
        "rack.multiprocess" => false,
        "rack.run_once" => false,
        "rack.hijack?" => false,
        "rack.logger" => @__settings__&.logger
      }
    end
    # rubocop: enable Metrics/MethodLength
    # rubocop: enable Metrics/AbcSize

    def uri
      @uri ||= Resolver::Uri.call(@__schema__, @__settings__)
    end

    def http_method
      @http_method ||= Resolver::HttpMethod.call(@__schema__, @__settings__)
    end

    def format
      @format ||= Resolver::Format.call(@__schema__, @__settings__)
    end

    def security
      @security ||= Resolver::Security.call(@__schema__, @__settings__)
    end

    def headers
      @headers ||= Resolver::Headers.call(@__schema__, @__settings__)
                                    .merge(security.fetch(:headers, {}))
                                    .merge("Content-Type" => content_type)
    end

    def query
      @query ||= Resolver::Query.call(@__schema__, @__settings__)
                                .merge(security.fetch(:query, {}))
    end

    def body
      @body ||= Resolver::Body.call(@__schema__, @__settings__)
    end

    def boundary
      @boundary ||= SecureRandom.hex(10)
    end

    def content_type
      case format
      when :text      then "text/plain"
      when :json      then "application/json"
      when :yaml      then "application/yaml"
      when :form      then "application/x-www-form-urlencoded"
      when :multipart then "multipart/form-data; boundary=#{boundary}"
      end
    end
  end
end
