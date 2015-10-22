# Поле имен для различных проектов Evil Martians
module Evil
  # Клиент отвечает за формирование адреса и отправку запроса к удаленному API.
  #
  # При создании клиента указывается +base_url+:
  #
  #    client = Client.with base_url: "127.0.0.1/v1"
  #
  # (В дальнейшем будет добавлен метод +Client.load+ для инициализации клиента
  # из спецификаций swagger etc.):
  #
  #    client = Client.load users: "users.json", sms: "sms.json"
  #
  # Все методы без восклицательного знака интерпретируются как части адреса:
  #
  #    client.users[1].sms
  #
  # Для получения строки адреса используется метод [#urn!]:
  #
  #    client.users[1].sms.urn! # => "127.0.0.1/v1/users/1/sms"
  #
  # Методы [#get!], [#post!], [#patch!], [#delete!] формируют и отправляют
  # запрос с переданными параметрами, возвращают (синхронный) ответ сервера
  # в виде +Hashie::Mash+.
  #
  #    response = client.users(1).sms.post! phone: "7101234567", text: "Hello!"
  #    response.class # => Hashie::Mash
  #    response.id    # => 100
  #    response.phone # => "7101234567"
  #    response.text  # => "Hello!"
  #
  # По умолчанию полный urn ищется по всем зарегистрированным API
  # (сейчас используется единственный API +base_url+).
  # При необходимости указать API явно, финализирующие методы могут вызываться
  # с его именем):
  #
  #    client.users(1).urn! :users
  #    # => "users.com/v1/users/1"
  #
  #    client.users(1).urn! :sms
  #    # => "sms.com/v1/users/1"
  #
  #    client.users(1).sms.post! :sms, phone: "7101234567", text: "Hello!"
  #
  # Перед возвращением проверяется статус ответа и в случае ошибки (4**, 5**)
  # выбрасывается исключение, содержащее ответ сервера.
  #
  # Если метод запроса вызывается с блоком, вместо обработки ошибочный ответ
  # сервера передается в блок. Результат обработки возвращается методом:
  #
  #    client.users(1).sms.post(phone: "7101234567") do |error_response|
  #      error_response.status
  #    end
  #    # => 400
  #
  class Client

    require_relative "client/errors"
    require_relative "client/urn"
    require_relative "client/api"
    require_relative "client/registry"

  end
end
