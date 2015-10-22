[WIP] Evil::Client
==================

DSL для работы с удаленными REST-ресурсами.

Установка
---------

Add this line to your application's Gemfile:

```ruby
# Gemfile
gem "evil-client"
```

Then execute:

```
bundle
```

Or add it manually:

```
gem install evil-client
```

Использование
-------------

### Инициализация

При создании клиента необходимо указать его `base_url`.

```ruby
client = Evil::Client.build base_url: "127.0.0.1/v1"
client.uri! # => "127.0.0.1/v1"
```

**Roadmap**: 

- [ ] *Будет поддерживаться инициализация файлами спецификаций swagger, где каждая спецификация определяет свой собственный `base_url`.*

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
# => "127.0.0.1/v1/users/1"

client.users[1].sms.uri!
# => "127.0.0.1/v1/users/1/sms"
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
