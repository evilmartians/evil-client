[WIP] Evil::Client
==================

DSL для работы с удаленными REST-ресурсами.

[swagger]: http://swagger.io

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

При инициализации клиента необходимо указать его `base_url`.

```ruby
require 'evil-client'

client = Evil::Client.new "127.0.0.1/v1"
client.url! # => "127.0.0.1/v1"
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

Методы с восклицательным знаком: `#url!` `#get!`, `#post!`, `#patch!` и `#delete!` финализируют адрес запроса.

Метод `#url!` возвращает строку адреса, включая `base_url`.

```ruby
client.users[1].url!
# => "127.0.0.1/v1/users/1"

client.users[1].sms.url!
# => "127.0.0.1/v1/users/1/sms"
```

**Roadmap**:

- [ ] *При финализации адрес будет автоматически проверяться на соответствие (всем выбранным) API*.
- [ ] *Адрес при финализации будет формироваться подходящим API (тем, которое имеет соответствующий адрес) с соответствующим `base_url`*.

### Вызов (отправка) запроса

Параметры запроса передаются в качестве атрибутов (хэш):

```ruby
client.users[1].sms.get!
client.users[1].sms.post! sms: { text: "Hello!" }, format: :json
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

В случае возврата ошибки, будет вызвано исключение с соответствующим кодом ошибки:

```ruby
client.users[1].sms.get!
# => #<ResponseError @status=404 ...>
```

### Специфический разбор ответа

Если метод вызывается с блоком, ему передается исходный ответ сервера (сырые данные), не преобразованные в хэш. Внутри блока пользователь может реализовать свою процедуру разбора данных. Результат разбора будет использоваться как возвращаемое значение метода:

```ruby
client.users[1].sms.get! { |response| JSON.parse(response)[:status].to_i }
# => 200
```

В этом случае исключение не вызывается - обработка ошибок оставляется на усмотрение пользователя.

**Roadmap**:

- [ ] *Перед конвертацией сырых данных в структуру, ответ будет проверяться на соответствие спецификации API. Вызываемое исключение будет содержать описание исходного запроса и полученного ответа*

Планы на будущее
----------------

* инициализация клиента файлами спецификаций swagger с разными `base_url`
* валидация адресов по спецификациям swagger
* валидация проверки запроса по соответствующей спецификации swagger
* валидация проверки ответа сервера по соответствующей спецификации swagger 
* использование спецификаций других форматов (помимо swagger): RABL, API blueprint и им подобных
* (?) миграция на `rom-http`, либо реализация клиента как отдельного адаптера

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
