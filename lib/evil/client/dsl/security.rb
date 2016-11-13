module Evil::Client::DSL
  # Nested definition for a security schemas
  class Security
    # Builds final security schema dependent on request options
    #
    # @param  [Hash<Symbol, Object>] options
    # @return [Hash<Symbol, Object>]
    #
    def call(**options)
      @mutex.synchronize do
        @schema = {}
        instance_exec(options, &@block)
        @schema
      end
    end

    private

    def initialize(&block)
      @mutex = Mutex.new
      @block = block
    end

    # ==========================================================================
    # Helper methods that mutate a security @schema
    # ==========================================================================

    # @see [https://tools.ietf.org/html/rfc7617]
    def basic_auth(user, password)
      token = Base64.encode64("#{user}:#{password}").delete("\n")
      token_auth(token, prefix: "Basic")
    end

    def token_auth(token, using: :headers, prefix: nil)
      if using == :headers
        prefixed_token = [prefix&.to_s&.capitalize, token].compact.join(" ")
        key_auth("authorization", prefixed_token, using: :headers)
      else
        key_auth("access_token", token, using: using)
      end
    end

    def key_auth(key, value, using: :headers)
      __validate__ using
      @schema[using] ||= {}
      @schema[using][key.to_s] = value
    end

    # ==========================================================================

    def __validate__(part)
      parts = %i(body query headers)
      return if parts.include? part
      raise ArgumentError.new "Wrong part '#{part}'. Use one of parts: #{parts}"
    end
  end
end
