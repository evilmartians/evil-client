class Evil::Client
  # Data structure describing a request to remote server
  #
  # Contains method to return a copy of the request updated with some data
  #
  # @api public
  #
  class Request

    require_relative "request/base_url"
    require_relative "request/comparison"
    require_relative "request/base"
    require_relative "request/items"
    require_relative "request/path"
    require_relative "request/body"
    require_relative "request/headers"

    include Comparison

    # Regex to remove terminal slashes from paths
    STRIP_SLASHES = %r{[^/].*[^/]|[^/]}.freeze

    # List of significant attributes assigned to the request
    ATTRIBUTES = %i(host port protocol path method query body headers).freeze

    # Initializes request with base url
    #
    # @param [String] base_url
    #
    def initialize(base_url)
      url = BaseURL.new(base_url)
      @host     = url.host
      @port     = url.port
      @parts    = [url.path]
      @protocol = url.protocol
    end

    # The method of sending the request
    #
    # @return [String]
    #
    attr_reader :method

    # The host of the request with protocol
    #
    # @return [String]
    #
    attr_reader :host

    # The relative path to the host
    #
    # @return [Array<String>]
    #
    attr_reader :path

    # The request port
    #
    # @return [Integer]
    #
    attr_reader :port

    # The request protocol
    #
    # @return [String]
    #
    attr_reader :protocol

    # The request headers
    #
    # @return [Hash<String, String>]
    #
    def headers
      @headers ||= {}
    end

    # The request body
    #
    # @return [Hash<String, String>]
    #
    def body
      @body ||= {}
    end

    # The request query
    #
    # @return [Hash<String, String>]
    #
    def query
      @query ||= {}
    end

    # The request path relative to the host
    #
    # @return [String]
    #
    def path
      "/" << @parts.map { |part| part.to_s[STRIP_SLASHES] }.compact.join("/")
    end

    # Returns a copy of the request with new parts added
    #
    # @param [Array<#to_s>] values
    #
    # @return [Evil::Client::Request]
    #
    def with_path(values)
      new_parts = [@parts, values].flatten
      clone_with { @parts = new_parts }
    end

    # Returns a copy of the request with new headers being added
    #
    # @param [Hash<#to_s, #to_s>] values
    #
    # @return [Evil::Client::Request]
    #
    def with_headers(values)
      new_headers = headers.merge(values)
      clone_with { @headers = new_headers }
    end

    # Returns a copy of the request with new values added to its query
    #
    # @param [Hash<#to_s, #to_s>] values
    #
    # @return [Evil::Client::Request]
    #
    def with_query(values)
      new_query = query.merge(values)
      clone_with { @query = new_query }
    end

    # Returns a copy of the request with new values added to its body
    #
    # @param [Hash<#to_s, #to_s>] values
    #
    # @return [Evil::Client::Request]
    #
    def with_body(values)
      new_body = body.merge(values)
      clone_with { @body = new_body }
    end

    # Returns a copy of the request with new method
    #
    # @param [#to_s] value
    #
    # @return [Evil::Client::Request]
    #
    def with_method(value)
      clone_with { @method = value.to_s.downcase }
    end

    # The array representation of the request
    # [method, host, path, port, body, headers]
    #
    # @see [Evil::Client::Adapter#call]
    #
    # @return [Array]
    #
    def to_a
      [
        method,
        host,
        Path.build(self),
        port,
        Body.build(self),
        Headers.build(self)
      ]
    end

    # The hash representation of the request
    #
    # @return [Hash]
    #
    def to_h
      ATTRIBUTES.zip(ATTRIBUTES.map { |name| send(name) }).to_h
    end

    private

    def clone_with(&block)
      dup.tap { |instance| instance.instance_eval(&block) }
    end
  end
end
