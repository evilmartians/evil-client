class Evil::Client::Middleware
  class StringifyQuery < Base
    private

    def build(env)
      return env if env&.fetch(:query, nil).to_h.empty?
      string = env[:query].flat_map { |key, val| normalize(val, key) }
                          .flat_map { |hash| stringify(hash) }
                          .join("&")

      env.merge(query_string: string)
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
