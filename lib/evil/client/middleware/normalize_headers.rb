class Evil::Client::Middleware
  class NormalizeHeaders < Base
    private

    def build(env)
      headers = Hash(env[:headers]).each_with_object({}) do |(key, val), hash|
        hash[key.to_s.downcase] = val.to_s
      end

      env.merge headers: headers
    end
  end
end
