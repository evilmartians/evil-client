class Evil::Client
  # Data structure describing a request to remote server
  #
  # Contains method to return a copy of the request updated with some data
  #
  # @api public
  #
  class Request

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
      @headers ||=
        if request_id
          DEFAULT_HEADERS.merge("X-Request-Id" => request_id)
        else
          DEFAULT_HEADERS
        end
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

    # The array of request parameters (query, body, headers)
    #
    # @return [Array]
    #
    def params
      [query, result_body, result_headers]
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
      str_values  = values.map { |k, v| [k.to_s, v.to_s] }.to_h
      new_headers = headers.merge(str_values)
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
      prepare_for_files!(values) if defined? ::Rails

      new_body = body.merge(values)
      clone_with { @body = new_body }
    end

    # Returns a copy of the request with a type added
    #
    # @param [String] raw_type
    #
    # @return [Evil::Client::Request]
    #
    def with_type(raw_type)
      type     = (raw_type == "get") ? "get" : "post"
      new_body = (raw_type == type) ? body : body.merge("_method" => raw_type)

      clone_with do
        @type     = type
        @raw_type = raw_type
        @body     = new_body
      end
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

    DEFAULT_HEADERS = {
      "Content-Type" => "application/json; charset=utf-8",
      "Accept"       => "application/json"
    }.freeze

    def request_id
      @request_id ||= RequestID.value
    end

    def clone_with(&block)
      dup.tap { |instance| instance.instance_eval(&block) }
    end

    def multipart?
      @raw_type == "post" && body_with_file?
    end

    def body_with_file?
      body.values.any? { |v| HTTP::Message.file?(v) }
    end

    def result_body
      result = body.dup

      if result.empty? || multipart?
        result
      else
        JSON.generate(result)
      end
    end

    def result_headers
      result = headers.dup

      if multipart?
        result.update("Content-Type" => "multipart/form-data")
      else
        result
      end
    end

    def prepare_for_files!(values)
      actiondispatch_files = values.find_all do |_, value|
        ActionDispatch::Http::UploadedFile =~ value
      end

      actiondispatch_files.each do |(key, file)|
        values.update(key => UploadFile.new(file))
      end
    end
  end
end
