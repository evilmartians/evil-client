class Evil::Client
  # Контейнер с настройками API
  #
  # Сейчас он просто хранит [#base_url].
  #
  #     api = API.new base_url: "127.0.0.1/v1"
  #     api.uri("/users/1/sms") # => "127.0.0.1/v1/users/1/sms"
  #
  # В дальнейшем он будет парсить и хранить спецификацию (swagger etc.)
  # и проверять наличие адреса по спецификации перед привязкой к [#base_url].
  #
  #     api = API.load("users.json")
  #     api.uri("/unknown") # => nil
  #
  # @api private
  #
  class API

    include Errors

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
      validate_base_url
    end

    # Формирует полный URI (base_url + адрес) из переданной строки адреса
    #
    # @param [String] path
    #
    # @return [String]
    #
    def uri(path)
      URI.join("#{base_url}/", path).to_s
    end

    # Предикат, проверяющий наличие адреса у текущего API
    # (добавлен для соответствия конвенции имен Rails)
    #
    # @param (see #uri)
    #
    # @return [Boolean]
    #
    def uri?(path)
      !!uri(path)
    end

    private

    def validate_base_url
      fail(URLError, base_url) unless URI(base_url).host
    end
  end
end
