class Evil::Client
  # Data structure describing a request to remote server
  #
  # Contains method to return a copy of the request updated with some data
  #
  # @api public
  #
  class Request

    require_relative "request/comparison"
    require_relative "request/base"
    require_relative "request/items"
    require_relative "request/path"
    require_relative "request/body"
    require_relative "request/headers"

    include Comparison

    # Converts path, or its part to list of safe parts without slashes
    PARTS = proc { |part| part.to_s[%r{[^/].*[^/]|[^/]}].to_s.split("/") }

    # List of significant attributes assigned to the request
    ATTRIBUTES = %i(method path query body headers).freeze

    # Builds the request from base uri
    #
    # @param  [URI] base_uri
    # @return [Evil::Client::Request]
    #
    def self.build(uri)
      parts = PARTS[uri.path]
      new parts
    end

    # Initializes request with parts of the root path without trailing slashes
    #
    # @param [Array<String>] parts
    #
    def initialize(parts)
      @parts = parts
    end

    # The method of sending the request
    #
    # @return [String]
    #
    attr_reader :method

    # The relative path to the host
    #
    # @return [Array<String>]
    #
    attr_reader :path

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
      "/" << @parts.compact.join("/")
    end

    # Returns a copy of the request with new parts added
    #
    # @param [Array<#to_s>] values
    #
    # @return [Evil::Client::Request]
    #
    def with_path(values)
      new_parts = @parts + values.map { |value| PARTS[value] }.flatten
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
      new_method = value.to_s.downcase
      clone_with { @method = new_method }
    end

    # Array representation of the request
    # [method, path, body, headers]
    #
    # @see [Evil::Client::Adapter#call]
    #
    # @return [Array]
    #
    def to_a
      [
        method,
        Path.build(self),
        Body.build(self),
        Headers.build(self)
      ]
    end

    # Hash representation of the raw request (before flattening body and query)
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
