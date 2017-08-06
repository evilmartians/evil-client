module Evil::Client::Formatter
  #
  # Utility module to format body/query as a form
  #
  # @example
  #   Evil::Client::Formatter::Form.call foo: { bar: [:baz] }, qux: 1
  #   # => "foo[bar][]=baz&qux=1"
  #
  module Form
    extend self

    # Formats nested hash as a string
    #
    # @param  [Hash] source
    # @return [String]
    #
    def call(source)
      case source
      when nil  then nil
      when Hash then normalize(source)
      else raise "#{source} is not a hash"
      end
    end

    private

    def normalize(value, *keys)
      case value
      when Hash then
        value.flat_map { |key, val| normalize(val, *keys, key) }.join("&")
      when Array then
        value.flat_map { |val| normalize(val, *keys, nil) }.join("&")
      else
        finalize(value, *keys)
      end
    end

    def finalize(value, key, *keys)
      value = CGI.escape(value.to_s)
      key   = CGI.escape(key.to_s)
      keys  = keys.map { |k| "[#{CGI.escape(k.to_s)}]" }
      "#{key}#{keys.join}=#{value}"
    end
  end
end
