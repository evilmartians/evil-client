# encoding: utf-8

require_relative "client/version"

module Evil
  # Клиент отвечает за формирование запроса к одному из удаленных API,
  # описанных в swagger-документациях.
  #
  # Инициализируется объектами документации:
  #
  #    client = Client.new API.new("/users.json", "/sms.yaml")
  #
  # или адресами к файлам:
  #
  #    client = Client.build("/users.json", "/sms.yaml")
  #
  # Все методы, кроме методов отправки запросов [#get, #post, #patch, #delete],
  # интерпретируются как методы подготовки адреса:
  #
  #    client.users(1).sms
  #
  # Методы отправки запроса проверяют и отправляют запрос,
  # возвращают (синхронный) ответ сервера в виде сырого хэша.
  # Ответ автоматически проверяется на соответствие документации.
  # 
  #    client.users(1).sms.post phone: "+710123456789", text: "Hello!"
  #    # => @todo: Пример структуры ответа
  #
  # Если метод запроса вызывается с блоком, аргументу блока передается
  # корректный (после проверки) набор данных для обработки,
  # например, преобразования в объект:
  #
  #    client.users(1).sms.post(phone: "+710123456789", text: "Hello!") do |response|
  #      Sms.new(response)
  #    end
  #
  # @author nepalez <nepalez@evilmartians.com>
  #
  class Client
    # Описывает удаленный API
    #
    # При инициализации парсит файл swagger-документации в одном
    # из допустимых форматов (yaml, json):
    #
    #     documentation = API.new("users.json")
    #     documentation = API.new("sms.yaml")
    #
    # @author nepalez <nepalez@evilmartians.com>
    #
    class API
    end

    # Коллекция нескольких удаленных API
    #
    # Инициализируется объектами документаций:
    #
    #     docs = APIs.new API.new("users.json"), API.new("sms.yaml")
    #
    # либо непосредственно исходными файлами:
    #
    #     docs = APIs.load "users.json", "sms.yaml"
    #
    # Порядок инициализации существенен - от него зависит, к какому из API
    # будет формироваться запрос в случае, когда один и тот же относительный
    # адрес объявлен несколькими API.
    #
    # @author nepalez <nepalez@evilmartians.com>
    #
    class APIs
    end

    # Построитель адреса запроса.
    #
    # Инициализируется с коллекцией API, используемых для проверки адреса:
    #
    #    docs = APIs.load "users.json", "sms.yaml"
    #    url = Url.new(docs)
    #
    # либо непосредственно из файлов:
    #
    #    url = Url.load "users.json", "sms.yaml"
    #
    # Вызов любого метода (кроме финализирующего метода [#call]) возвращает
    # обновленный (промежуточный) объект. Никакие проверки при этом не
    # выполняются, поскольку итоговый адрес может принадлежать разным API.
    #
    #    url.users
    #    # => #<Url @url = "/users">
    #    url.users.id(1)
    #    # => #<Url @url = "/users/1">
    #    url.users(1)
    #    # => #<Url @url = "/users/1">
    #    url.users(1).sms
    #    # => #<Url @url = "/users/1/sms">
    #
    # При финализации методом [#call] выполняется окончательная проверка
    # корректности. Если адрес корректен, возвращается соответствующий
    # ленивый запрос [Request], привязанный уже к конкретному API.
    #
    #    request = url.users(1).sms.call
    #    request.class # => Evil::Client::Request
    #    request.url   # => "sms-service.com:8081/v1/users/1/sms"
    #
    # Если адрес не соответствует ни одному из API, выбрасывается исключение:
    #
    #    url.cats(1)
    #    # => #<UrlError "unknown address '/cats/1' cannot be resolved to url">
    #
    # @author nepalez <nepalez@evilmartians.com>
    #
    class Url
    end

    # Проверяет данные запроса на соответствие формату документации.
    #
    # Инициализируется объектом API и строкой его адреса (предполагается,
    # что объект будет инициализирован из [Url]).
    #
    #     request = Request.new \
    #       API.new("users.json"),
    #       "sms-service.com:8081/v1/users/1/sms"
    #
    # После инициализации методы [#get], [#post], [#patch], [#delete]
    # с соотв.параметрами используются для формирования и проверки
    # параметров запроса к API
    #
    #     request.post \
    #       format: :json,
    #       parameters: {text: "Hello!"},
    #       protocol: "https"
    #     # => @todo: пример структуры данных rack
    #
    # @author nepalez <nepalez@evilmartians.com>
    #
    class Request
    end

    # Проверяет ожидаемый ответ сервера
    #
    # Инициализируется объектом исходного запроса.
    #
    #    request  = Url.load("users.json").users(1).sms.get
    #    response = Response.new(request)
    #
    # Метод [#call] проверяет соответствие ответа (в виде хэша)
    # требованиям документации и выбрасывает исключение в случае расхождений:
    #
    #    response.call(id: 1, pet_name: "Livingston")
    #    # => <ResponseError "Unexpected key :pet_name">
    #
    # При успешной проверке возвращает свой аргумент.
    #
    # @author nepalez <nepalez@evilmartians.com>
    #
    class Response
    end
  end # class Client
end # module Evil
