class Evil::Client
  #
  # Resolves security definitions from operation settings and schema.
  # Defines helpers for different methods of the authentication.
  # @private
  #
  class Resolver::Security < Resolver
    # DSL method to provide basic authentication schema
    # by user name and password
    #
    # It provides base64-encoded "user:password" token and adds it
    # to the "Authorization" header with a "Basic" prefix.
    #
    # @example
    #   operation do
    #     option :user
    #     option :password
    #
    #     security { basic_auth user, password }
    #   end
    #
    # @param [#to_s] user User name
    # @param [#to_s] password Password
    # @return [Hash<:headers, Hash<Symbol, String>>]
    #
    def basic_auth(user, password)
      token = Base64.encode64("#{user}:#{password}").delete("\n")
      token_auth(token, prefix: "Basic")
    end

    # DSL method to provide token-based authentication schema
    #
    # It places the token under either standard "Authorization" header,
    # or standard "access_token" parameter of body or query.
    # If you need custom key use [#key_auth] schema instead.
    #
    # @example
    #   operation do
    #     option :token
    #     security { token_auth token, prefix: "Bearer" }
    #   end
    #
    # @param  [#to_s] token User secret token
    # @option [#to_s, nil] :prefix The standard prefix to be added before token
    # @option [:headers, :query] :inside (:headers)
    #   The part of the request for the token
    # @return [Hash<Symbol, Hash<Symbol, String>>]
    #
    def token_auth(token, inside: :headers, prefix: nil)
      if inside == :headers
        prefixed_token = [prefix&.to_s&.capitalize, token].compact.join(" ")
        key_auth("Authorization", prefixed_token, inside: :headers)
      else
        key_auth("access_token", token, inside: inside)
      end
    end

    # DSL method to provide the key-based authentication schema
    #
    # @example
    #   operation do
    #     option :key
    #     security { key_auth "Authorize", key }
    #   end
    #
    # @param [#to_s] key   Name of the parameter
    # @param [#to_s] value Value of the parameter
    # @option [:headers, :query] :inside (:headers)
    #   The part of the request for the key-value pair
    # @return [Hash<Symbol, Hash<Symbol, String>>]
    #
    def key_auth(key, value, inside: :headers)
      { inside => { key.to_s => value.to_s } }
    end

    private

    def initialize(schema, settings)
      super schema, settings, :security
    end

    def __call__
      super do
        value = __blocks__.any? ? Hash(instance_exec(&__blocks__.last)) : {}
        raise __wrong_format_error__(value) unless value.is_a? Hash

        __symbolize_keys__(value).tap do |val|
          __check_format__(val)
          __check_values__(val)
        end
      end
    end

    def __check_format__(value)
      data = value.keys - %i[headers query]
      return if data.empty?

      raise __definition_error__ "#{value.inspect} is not a hash"
    end

    def __check_values__(value)
      data = value.reject { |_, val| val.is_a? Hash }
      return if data.empty?

      message = "inacceptable parts :#{data} of the request"
      raise __definition_error__(message)
    end

    def __wrong_value_error__(data)
      __definition_error__ "inacceptable security settings #{data}"
    end
  end
end
