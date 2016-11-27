class Evil::Client::Middleware
  class MergeSecurity < Base
    def call(env, schema, options)
      super build(env), schema, options
    end

    private

    def build(env)
      env.dup.tap do |hash|
        security = hash.delete(:security).to_h
        %i(headers body query).each do |key|
          next unless security[key]
          hash[key] ||= {}
          hash[key].update security[key]
        end
      end
    end
  end
end
