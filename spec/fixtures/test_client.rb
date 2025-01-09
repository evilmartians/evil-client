module Test
  class Client < Evil::Client
    option :subdomain
    option :user
    option :token,    optional: true
    option :password, optional: true

    validate { errors.add :valid_credentials unless token.nil? ^ password.nil? }

    path { "https://#{subdomain}.example.com" }

    response(200)
    response(404) { raise "Not found" }
    response(500) { raise "Server error" }

    scope :crm do
      option :version, default: proc { 1 }
      format { version.to_i > 2 ? :json : :form }
      path   { "crm/v#{version}" }

      scope :users do
        path "users"

        operation :filter do
          option :name,  optional: true
          option :id,    optional: true
          option :email, optional: true

          validate { errors.add :filter_given unless name || id || email }

          http_method   :get
          response(200) { |*res| res.last.flat_map { |item| item&.!=("") ? JSON.parse(item) : [] } }
        end

        operation :fetch do
          option :id

          path        { id }
          http_method :get
        end

        operation :create do
          option :name
          option :language
          option :email, optional: true

          http_method :post
          security    { token ? token_auth(token) : basic_auth(user, password) }
          body        { options.select { |k| %i[name email].include? k } }
          query       { { language: language } }
          response    201
        end

        operation :update do
          option :id
          option :name
          option :language
          option :email, optional: true

          path        { id }
          http_method { version > 2 ? :patch : :put }
          security    { token ? token_auth(token) : basic_auth(user, password) }
          body        { options.select { |k| %i[name email].include? k } }
          query       { { language: language } }
        end

        operation :drop do
          option :id

          path        { id }
          http_method { :delete }
          security    { token ? token_auth(token) : basic_auth(user, password) }
        end
      end
    end
  end
end
