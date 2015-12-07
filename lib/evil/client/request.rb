class Evil::Client
  # Data structure describing a request to remote server
  #
  # Contains method to return a copy of the request updated with some data
  #
  # @api public
  #
  class Request

    require_relative "request/base"
    require_relative "request/body"
    require_relative "request/headers"
    require_relative "request/request_id"
    require_relative "request/multipart"

    # Initializes request with base url
    #
    # @param [String] base_url
    #
    def initialize(base_url)
      @path = base_url.to_s.sub(%r{/+$}, "")
    end

    # The type of the request
    #
    # @return ["get", "post"]
    #
    attr_reader :type

    # The request path
    #
    # @return [String]
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

    # Returns a copy of the request with new parts added to the uri
    #
    # @param [#to_s, Array<#to_s>] parts
    #
    # @return [Evil::Client::Request]
    #
    def with_path(*parts)
      paths    = parts.flat_map { |part| part.to_s.split("/").reject(&:empty?) }
      new_path = [path, *paths].join("/")
      clone_with { @path = new_path }
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

    # Returns a copy of the request with a type added
    #
    # @param [String] type
    #
    # @return [Evil::Client::Request]
    #
    def with_type(type)
      clone_with { @type = type }
    end

    # Checks whether a request is a multipart
    #
    # @return [Boolean]
    #
    def multipart?
      @multipart = false
      apply(body) { |leaf| @multipart = true if HTTP::Message.file?(leaf) }
      @multipart
    end

    # Returns parameters of the request: query, body, headers
    #
    # @return [Array]
    #
    def params
      [query, Body.build(self), Headers.build(self)]
    end

    # Returns a standard array representation of the request
    #
    # @see [Evil::Client::Adapter#call]
    #
    # @return [Array]
    #
    def to_a
      [type, path, *params]
    end

    private

    def clone_with(&block)
      dup.tap { |instance| instance.instance_eval(&block) }
    end

    def apply(value, &fn)
      if value.is_a? Hash
        value.inject({}) { |a, (key, val)| a.update(key => apply(val, &fn)) }
      elsif value.is_a? Array
        value.map { |val| apply(val, &fn) }
      else
        fn[value]
      end
    end
  end
end
