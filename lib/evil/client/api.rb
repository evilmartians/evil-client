class Evil::Client
  # Контейнер с настройками API
  #
  # Сейчас он просто хранит [#base_url].
  #
  #     api = API.new base_url: "127.0.0.1/v1"
  #     api.uri("/users/1/sms") # => "127.0.0.1/v1/users/1/sms"
  #
  # В дальнейшем он будет парсить и хранить спецификацию (swagger etc.)
  # и проверять наличие URN по спецификации перед его привязкой к [#base_url].
  #
  #     api = API.load("users.json")
  #     api.uri("/unknown") # => nil
  #
  # @api private
  #
  class API
    # @!attribute [r] base
    #
    # @return [String] базовый адрес RESTful API
    #
    attr_reader :base_url

    # @!method initialize(options)
    # Инициализирует спецификацию удаленного API с указанными параметрами
    #
    # @param [<type>]
    # @option options [String] :base_url
    #
    def initialize(base_url:)
      @base_url = base_url
    end

    # Формирует полный URI (base_url + URN) из переданной строки URN
    #
    # @param [String] urn
    #
    # @return [String]
    #
    def uri(urn)
      File.join(base_url, urn) # @todo: Решить про использование протокола!
                               # Можно было бы использовать URI.join,
                               # но URI требует указания протокола base_url
    end

    # Предикат, проверяющий наличие URN у текущего API
    # (добавлен для соответствия конвенции имен Rails)
    #
    # @param (see #uri)
    #
    # @return [Boolean]
    #
    def uri?(urn)
      !!uri(urn)
    end
  end
end
