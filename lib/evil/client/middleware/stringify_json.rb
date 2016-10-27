class Evil::Client::Middleware
  class StringifyJson < Base
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
