[WIP] Evil::Client
==================

DSL для работы с REST-ресурсами удаленных API.

[swagger]: http://swagger.io

Installation
------------

Add this line to your application's Gemfile:

```ruby
Gemfile
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

Synopsis
--------

### Инициализация

Инициализируется набором файлов swagger (в форматах `yaml` или `json`), описывающих различные удаленные API:

```ruby
require 'evil-client'
dsl = Evil::Client.new("/config/users.json", "/config/sms.json")
```

### Подготовка адреса

Все методы, кроме `#to_url`, `#get`, `#post`, `#patch`, `#delete`, интерпретируются как части адреса:

```ruby
url = dsl.users
url = dsl.users.id(1)
url = dsl.users(1)
url = dsl.users(1).sms
```

Метод `#to_url` финализирует адрес и проверяет его на соответствие документации.

Проверка выполняется среди всех удаленных API в порядке их инициализации. Например, если `sms.json` и `users.json` содержат адрес `"/users/1"`, то при поиске адреса `dsl.users(1)` он будет взят из `users.json`, поскольку при инициализации он был указан первым.

В случае ошибки (сформированный адрес не объявлен ни одним из API) выбрасывается исключение:

```ruby
dsl.unknown.to_url
# => #<Evil::Client::UrlError "The url '127.0.0.1/v1/unknown' doesn't match the documentation>">
```

Эта проверка также автоматически выполняется при вызове любого метода отправки запроса.

Помимо адреса, перед отправкой проверяется, что все переданные параметры соответствуют документации:

```ruby
dsl.users(1).sms.post
# => #<Evil::Client::RequestError "The text of SMS should be set as a [:sms][:text]">
```

Необходимые параметры запроса передаются в виде аргументов:

```ruby
dsl.users(1).sms.post parameters: { sms: { text: "Hello!" } }, protocol: "https"
```

Возвращаемое значение анализирутся на соответствие документации. Если полученные данные не соответствуют ожиданиям (сервер вернул что-то странное), выбрасывается исключение. При этом как исходный запрос, так и полученный ответ доступны через методы исключения `#request` и `#responce`:

```ruby
begin
  dsl.users(1).sms.post text: "Hello"
rescue Evil::Client::ResponceError => error
  error.message
  # => "The result of request doesn't contain required :id"
  error.responce
  # => {status: 200, sms: { text: "Hello" }
  error.request
  # => #<Evil::Client::Request @url='127.0.0.1/v1/users/1/sms'>
end
```

Результат запроса сериализуется в виде хэша:

```ruby
dsl.users(1).sms.get
# => { status: 200, parameters: { sms: [{ id: 1, text: "Hello!" }] } }
```

Если метод вызван с блоком, сырой результат запроса после проверки передается в блок для дальнейшей обработки - например, инициализации доменной модели:

```ruby
dsl.users(1).sms.get do |responce|
  Sms.new responce[:sms]
end
# => #<Sms @id=1, @text="Hello!">
```

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

Tested under rubies [compatible to MRI 1.9+](.travis.yml).

Uses [RSpec] 3.0+ for testing and [hexx-suit] for dev/test tools collection.

[RSpec]: http://rspec.org
[hexx-suit]: https://github.com/nepalez/hexx-suit

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
