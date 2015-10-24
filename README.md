[WIP] Evil::Client
==================

DSL для работы с REST-ресурсами.

Установка
---------

This library is available as a gem `evil-client`.

Использование
-------------

### Инициализация

При создании клиента необходимо указать его `base_url` и `client_id`.

```ruby
client = Evil::Client.with base_url: "http://127.0.0.1/v1", client_id: "82iudri"
client.uri! # => "http://127.0.0.1/v1"
```

При использовании в составе приложения Rails параметр `client_id` устанавливается автоматически из railtie `"evil.client.rails.request_id"`.

**Roadmap**: 

- [ ] *Будет поддерживаться инициализация файлами спецификаций swagger, где каждая спецификация определяет свой собственный `base_url` и `client_id`.*

### Подготовка адреса

RESTful адрес запроса формируется цепочкой методов клиента. Все методы, не оканчивающиеся восклицательным знаком, интерпретируются как части адреса:

```ruby
client.users
client.users[1]
client.users[1].sms
```

Квадратные скобки используются для передачи динамических параметров адреса.

### Финализация адреса

Методы с восклицательным знаком: `#uri!` `#get!`, `#post!`, `#patch!` и `#delete!` финализируют адрес запроса.

Метод `#uri!` возвращает строку адреса, включая `base_url`.

```ruby
client.users[1].uri!
# => "http://127.0.0.1/v1/users/1"

client.users[1].sms.uri!
# => "http://127.0.0.1/v1/users/1/sms"
```

**Roadmap**:

- [ ] *При финализации адрес будет автоматически проверяться на соответствие (всем выбранным) API*.
- [ ] *Адрес при финализации будет формироваться подходящим API (тем, которое имеет соответствующий адрес) с соответствующим `base_url`*.

### Вызов (отправка) запроса

Параметры запроса передаются в качестве атрибутов (хэш) методам `#get!`, `#post!`, `#patch!` и `#delete!`:

```ruby
client.users[1].sms.get!
client.users[1].sms.post! text: "Hello!"
```

**Roadmap**:

- [ ] *Перед отправкой параметры запроса будут проверяться на соответствие спецификации соответствюущего API*.

### Получение и обработка ответа по-умолчанию

Методы `#get!`, `#post!`, `#patch!`, `#delete!` возвращают расширенный хэш ([`Hashie::Mash`][mash]), извлеченный из тела ответа.

```ruby
results = client.users[1].sms.get!
results.first.class # => Mash
results.first.text  # => "Hello!"
```

Перед преобразованием в +Mash+ проверяется статус ответа. В случае ошибки (статусы 4**, 5**), вызывается исключение с соответствующим статусом, а также данными ответа:

```ruby
begin
  client.unknown.get!
rescue Evil::Client::ResponseError => error
  error.status    # => 404
  error.response  # => #<Mash ...>
end
```

### Специфический разбор ответа

Если метод вызывается с блоком, то в случае ошибки вместо вызова исключения ответ (response) передается в блок. Внутри блока пользователь может реализовать свою процедуру обработки ошибки. Метод вернет результат обработки:

```ruby
client.userss.get! { |error_response| error_response.status }
# => 404
```

Формат ответа сервера (`error_response`) см. в [документации к гему 'httpclient'][client-message].

**Roadmap**:

- [ ] *Перед конвертацией сырых данных в структуру, ответ будет проверяться на соответствие спецификации API. Вызываемое исключение будет содержать описание исходного запроса и полученного ответа*

Планы на будущее
----------------

* инициализация клиента json файлами спецификаций swagger с разными `base_url`
* валидация адресов по спецификациям swagger
* валидация проверки запроса по соответствующей спецификации swagger
* валидация проверки ответа сервера по соответствующей спецификации swagger 
* использование спецификаций других стандартов (помимо swagger: RAМL, API blueprint и т.п.) и форматов (json, yaml...)

Tests
-----

Для запуска тестов используйте:

```
rake
```

Для мутационного тестирования:

```
rake exhort
```

или (останавливается при первой непокрытой тестами мутации):

```
rake mutant
```

Запуск всех метрик перед коммитом:

```
rake prepare
```

Compatibility
-------------

Tested under rubies [compatible to MRI 2.2+](.travis.yml).

Uses [RSpec][rspec] 3.0+ for testing and [hexx-suit][hexx-suit] for dev/test tools collection.

Contributing
------------

* Read the [STYLEGUIDE](config/metrics/STYLEGUIDE)
* [Fork the project](https://github.com/evilmartians/evil-client)
* Create your feature branch (`git checkout -b my-new-feature`)
* Add tests for it
* Commit your changes (`git commit -am '[UPDATE] Add some feature'`)
* Push to the branch (`git push origin my-new-feature`)
* Create a new Pull Request

License
-------

@todo

[mash]: https://github.com/intridea/hashie#mash
[rspec]: http://rspec.org
[hexx-suit]: https://github.com/nepalez/hexx-suit
[swagger]: http://swagger.io
[client-message]: http://www.rubydoc.info/gems/httpclient/HTTP/Message
