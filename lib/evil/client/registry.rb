class Evil::Client
  # Коллекция нескольких именованных API с возможностью поиска адреса среди них
  #
  # Сейчас это "пустая" обертка вокруг единственного API.
  #
  #     api  = API.new base_url: "127.0.0.1/v1"
  #     registry = Registry.new(default: api)
  #     registry[:default] == api # => true
  #
  # Или сокращенно:
  #
  #     registry = Registry.with base_url: "127.0.0.1/v1"
  #
  # В дальнейшем коллекция будет инициализироваться файлами спецификаций:
  #
  #     registry = Registry.load(users: "users.json", sms: "sms.json")
  #
  # Метод [#api] возвращает <пока единственный> API.
  #
  #     Registry.api path: "users/1/sms"
  #
  # В дальнейшем этот метод будет выполнять поиск того из API, где определен
  # указанный адрес. API просматриваются в порядке, определенном при
  # инициализации. Если один и тот же адрес определен несколькими API,
  # то поиск может быть выполнен только среди указанного подмножества:
  #
  #    Registry.api :users, :sms, path: "users/1"
  #
  # Если адрес не найден, выбрасывается исключение:
  #
  #    Registry.api path: "/unknown"
  #    # => #<Evil::Client::Errors::PathError ...>
  #
  # @api private
  #
  class Registry
    include Enumerable, Errors

    # @!scope class
    # @!method with(options)
    # Формирует коллекцию из единственного API с заданными параметрами
    #
    # @param [Hash] options
    # @option options [String] :base_url
    #
    # @return [Evil::Client::Registry]
    #
    def self.with(base_url:)
      new default: API.new(base_url: base_url)
    end

    # @!method initialize(apis)
    # Инициализирует коллекцию именованным набором <спецификаций к> API
    #
    # @param [Hash<Symbol, Evil::Client::API>] apis
    #
    def initialize(**apis)
      @apis = apis
    end

    # Выполняет итерации по зарегистрированным <спецификациям к> API
    #
    # @param [Proc] block
    #
    # @return [Enumerator<Evil::Client::API>]
    #
    def each(&block)
      @apis.values.each(&block)
    end

    # Возвращает коллекцию с подмножеством API, имеющих указанные имена
    #
    # @param [Symbol, Array<Symbol>] keys
    #
    # @return [Evil::Client::Registry]
    #
    def filter(*keys)
      keys.any? ? self.class.new(@apis.select { |k| keys.include? k }) : self
    end

    # Находит и возвращает API, содержащий запрашиваемый адрес
    #
    # @param [Symbol, Array<Symbol>] keys
    #   Имена API, среди которых ведется поиск адреса
    # @option options [String] :path
    #   Адрес, для которого ищется подходящий API
    #
    # @return [Evil::Client::API] API, у которого есть искомый адрес
    #
    # @raise [Evil::Client::Errors::ULRError]
    #   если сформированный адрес не распознан <ни одним из объявленныx> API
    #
    def api(*keys, path:)
      filter(*keys).detect { |api| api.uri(path) } ||
        fail(PathError.new path, keys)
    end
  end
end
