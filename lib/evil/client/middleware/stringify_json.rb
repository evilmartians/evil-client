class Evil::Client::Middleware
  class StringifyJson < Base
    def call(env, schema, options)
      super build(env), schema, options
    end

    private

    def build(env)
      return env unless env[:format] == "json"

      env.dup.tap do |hash|
        hash[:headers] ||= {}
        hash[:headers]["content-type"] = "application/json"
        hash[:body_string] = JSON.generate(env[:body].to_h)
      end
    end
  end
end
