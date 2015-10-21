class Evil::Client
  # Построитель адреса запроса.
  #
  # Любой метод (объекта или класса) интерпретируется как часть адреса
  # и возвращает обновленный объект с добавленной частью.
  #
  # Метод [#call] (с алиасом +[]+) используется для вставки в адрес
  # динамической части.
  #
  # Метод [#call!] без аргументов возвращает итоговую строку
  # (не привязанную к +base_url+).
  #
  #     URL.users[1].sms.call! # => "/users/1/sms"
  #
  # @api private
  #
  # @author nepalez <nepalez@evilmartians.com>
  #
  class URL
    def initialize
      @parts = []
    end

    def call(part)
      dup.tap do |instance|
        instance.instance_eval { @parts = @parts + [part.to_s] }
      end
    end

    def call!
      @parts.join("/")
    end

    private

    REGULAR = /^\w+$/

    def self.method_missing(name, *)
      new.send(name)
    end

    def self.respond_to_missing?(name, *)
      name[REGULAR] ? true : false
    end

    def method_missing(name, *)
      name[REGULAR] ? call(name) : super
    end

    def respond_to_missing?(name, *)
      name[REGULAR] ? true : false
    end
  end # class URL
end # class Evil::Client
