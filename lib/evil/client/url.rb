class Evil::Client
  # Построитель адреса запроса.
  #
  # Любой метод (объекта или класса) без восклицательных знаков интерпретируется
  # как часть адреса и возвращает обновленный URL с добавленной частью.
  #
  # Метод [#call] (с алиасом +[]+) используется для вставки в адрес
  # динамической части (также возвращает обновленный URL).
  #
  # Метод [#url!] без аргументов возвращает итоговую строку
  # (не привязанную к +base_url+).
  #
  #     URL.users[1].sms.url! # => "users/1/sms"
  #
  # @api private
  #
  class URL
    # Добавляет динамическую часть к адресу и возвращает обновленный адрес
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::URL]
    #
    def call(part)
      self.class.new(@parts + [part])
    end

    # Возвращает сформированную строку адреса
    #
    # @return [String]
    #
    def url!
      @parts.join("/")
    end

    protected

    # Изменяет текущий объект путем добавления к нему части адреса
    #
    # @param [#to_s] part
    #
    # @return [Evil::Client::URL]
    #
    def call!(part)
      @parts << part
      self
    end

    private

    REGULAR = /^\w+$/

    def initialize(parts = [])
      @parts = parts
    end

    def method_missing(name, *args)
      (name[REGULAR] && args.empty?) ? call(name) : super
    end

    def respond_to_missing?(name, *)
      !!name[REGULAR]
    end

    def self.method_missing(*args)
      new.public_send(*args)
    end

    def self.respond_to_missing?(name, *)
      !!name[REGULAR]
    end
  end
end
