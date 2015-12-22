class Evil::Client
  # Data structure describing a request to remote server
  #
  # Contains method to return a copy of the request updated with some data
  #
  # @api public
  #
  class Request

    require_relative "request/item"
    require_relative "request/items"
    require_relative "request/request_id"

    require_relative "request/path"
    require_relative "request/method"
    require_relative "request/query"
    require_relative "request/body"
    require_relative "request/headers"

    # Initializes request with base path
    #
    # @param [String] base_path
    #
    def initialize(base_path)
      @path    = Path.new(base_path)
      @headers = Headers.new
      @body    = Body.new
      @query   = Query.new
    end

    # @!attribute [r] method
    #
    # @return [String] The method of sending the request
    #
    attr_reader :method

    # @!attribute [r] path
    #
    # @return [Evil::Client::Request::Path] The object representing a path
    #
    attr_reader :path

    # @!attribute [r] headers
    #
    # @return [Evil::Client::Request::Headers] The object representing headers
    #
    attr_reader :headers

    # @!attribute [r] body
    #
    # @return [Evil::Client::Request::Body] The object representing a body
    #
    attr_reader :body

    # @!attribute [r] query
    #
    # @return [Evil::Client::Request::Query] The object representing a query
    #
    attr_reader :query

    # Returns a copy of the request with new parts added
    #
    # @param [Array<#to_s>] values
    #
    # @return [Evil::Client::Request]
    #
    def with_path(values)
      new_parts = path + values
      clone_with { @path = new_parts }
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
      clone_with { @method = Method.new(value) }
    end

    # Full path of the request including relative path and query
    #
    # @return [String]
    #
    def full_path
      [path.final, query.final].compact.join("?")
    end

    # Array representation of the request
    # [method, path, body, headers]
    #
    # @see [Evil::Client::Adapter#call]
    #
    # @return [Array]
    #
    def to_a
      [method, full_path, body.final, headers.final(self)]
    end

    # Human-readable representations of the request
    #
    # @return [String]
    #
    def inspect
      "#{method} #{full_path} with" \
      " headers: #{headers.inspect}," \
      " body: #{body.inspect}"
    end

    private

    def clone_with(&block)
      dup.tap { |instance| instance.instance_eval(&block) }
    end
  end
end
