class Evil::Client::Middleware
  class NormalizeHeaders < Base
    def call(env, schema, options)
      super build(env), schema, options
    end

    private

    def build(env)
      headers = Hash(env[:headers]).each_with_object({}) do |(key, val), hash|
        hash[key.to_s.downcase] = val.to_s
      end

      env.merge headers: headers
    end
  end
end
