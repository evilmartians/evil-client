class Evil::Client::Middleware
  class StringifyForm < Base
    def call(env, schema, options)
      super build(env), schema, options
    end

    private

    def build(env)
      return env unless env[:format] == "form"
      return env if env&.fetch(:body, nil).to_h.empty?

      env.dup.tap do |hash|
        hash[:headers] ||= {}
        hash[:headers]["content-type"] = "application/x-www-form-urlencoded"
        hash[:body_string] = env[:body]
                             .flat_map { |key, val| normalize(val, key) }
                             .flat_map { |item| stringify(item) }
                             .join("&")
      end
    end

    def stringify(hash)
      hash.map do |keys, val|
        "#{keys.first}#{keys[1..-1].map { |key| "[#{key}]" }.join}=#{val}"
      end
    end

    def normalize(value, *keys)
      case value
      when Hash then
        value.flat_map { |key, val| normalize(val, *keys, key) }
      when Array then
        value.flat_map { |val| normalize(val, *keys, nil) }
      else
        [{ keys.map { |key| CGI.escape(key.to_s) } => CGI.escape(value.to_s) }]
      end
    end
  end
end
