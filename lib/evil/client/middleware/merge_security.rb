class Evil::Client::Middleware
  class MergeSecurity < Base
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
